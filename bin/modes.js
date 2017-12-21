// imports
var path = require('path');
var mkdirp = require("mkdirp");
var fs = require("fs");
var Elm = require("./elm.js");
var helpers = require('./cli-helpers.js');
var rimraf = require('rimraf')



/* Running modes currently supported are either
   - generate, to generate tests as part of your suite
   - run, to run a single file, provide the file name
*/
var RUNNING_MODE = {
  GENERATE: 0,
  RUN: 1
};

// runners are called via `.run` on a model
var running_mode_runners = {};
running_mode_runners[RUNNING_MODE.GENERATE] = generate;
running_mode_runners[RUNNING_MODE.RUN] = run;


// loaders are called by init
var running_mode_loaders = {};

running_mode_loaders[RUNNING_MODE.GENERATE] = function(options){
  var verifyExamplesConfig = helpers.loadVerifyExamplesConfig(options.configPath);

  return {
    runningMode: RUNNING_MODE.GENERATE,
    config: verifyExamplesConfig,
    run: running_mode_runners[RUNNING_MODE.GENERATE],
    showWarnings: options.showWarnings,
    output: options.output,
    configPath: options.configPath
  };
};

running_mode_loaders[RUNNING_MODE.RUN] = function(argv, options){
  var verifyExamplesConfig = helpers.loadVerifyExamplesConfig(options.configPath);
  var tests = argv.run;

  verifyExamplesConfig.tests = tests;

  return {
    runningMode: RUNNING_MODE.RUN,
    config: verifyExamplesConfig,
    run: running_mode_runners[RUNNING_MODE.RUN],
    showWarnings: options.showWarnings,
    output: options.output,
    configPath: options.configPath
  };
};


// parse args
function init(argv){
  var model = null;
  var defaultConfigPath = path.join(process.cwd(), 'tests/elm-verify-examples.json');

  var options = {
    showWarnings: true,
    output: "tests",
    configPath: defaultConfigPath
  };

  if (typeof argv.warn !== "undefined") {
    options.showWarnings = argv.warn;
  }

  if (typeof argv.output !== "undefined") {
    options.output = argv.output;
  }

  if (typeof argv.config !== "undefined") {
    options.configPath = argv.config;
  }

  if (typeof argv.run === "undefined") {
    if (options.showWarnings) console.log('Running in generate mode..');
    model = running_mode_loaders[RUNNING_MODE.GENERATE](options);
  } else {
    if (options.showWarnings) console.log('Running in run mode..');
    model = running_mode_loaders[RUNNING_MODE.RUN](argv, options);
  }

  return model;
}

function run(model, allTestsGenerated){
  var config = model.config;
  var tests = config.tests.split(' ');
  config.tests = tests.filter(
    function(v){ return v.endsWith('.elm'); }
  ).map(elmPathToModule);


  model.config = config;
  generate(model, allTestsGenerated);
}

function generate(model, allTestsGenerated) {
  var config = model.config;
  var testsPath = path.join(
    process.cwd(),
    "tests"
  );
  var testsDocPath = path.join(model.output, "Doc");
  rimraf.sync(testsDocPath);

  if (config.tests.length === 0){
    if (model.showWarnings) {
      console.log('No tests listed! Modify your elm-verify-examples.json file to include modules');
    }
    return;
  }

  var app = Elm.VerifyExamples.worker(config);

  app.ports.readFile.subscribe(function(test) {
    var pathToModule = path.join(
      testsPath,
      config.root,
      elmModuleToPath(test)
    );
    fs.readFile(
        pathToModule,
        "utf8",
        function(err, data) {
      if (err) {
        console.error(err);
        process.exit(-1);
        return;
      }
      app.ports.generateModuleVerifyExamples.send([test, data]);
    });
  });

  var writtenTests = 0;
  app.ports.writeFiles.subscribe(function(data) {
    serial(data, writeFile(testsDocPath), function() {
        writtenTests = writtenTests + 1;
        if (writtenTests === config.tests.length && allTestsGenerated) {
          allTestsGenerated();
        }
    });
  });
}

function serial(xs, f, done) {
  var run = function(x, rest) {
    f(x, function() {
      if (rest.length > 0) {
        run(rest[0], rest.slice(1));
      } else {
        done();
      }
    });
  };
  run(xs[0], xs.slice(1));
}

function writeFile(testsDocPath) {
  return function (data, done) {
    var test = data[1];
    var parts = data[0].split(".");
    var modulePath = [];
    var moduleName = ".";

    if (parts.length > 1) {
      modulePath = parts.slice(0, -1);
      moduleName = parts.slice(-1)[0];
    } else {
      moduleName = parts[0];
    }

    var testsDocModulePath = path.join(
      testsDocPath,
      modulePath.join("/")
    );

    mkdirp(testsDocModulePath, function(err) {
      if (err) {
        console.error(err);
        process.exit(-1);
        return;
      }
      fs.writeFile(
        path.join(testsDocModulePath, moduleName + "Spec.elm"),
        test,
        "utf8",
        function(err) {
          if (err) {
            console.error(err);
            process.exit(-1);
            return;
          }

          done();
      });
    });
  };
}

function elmPathToModule(pathName){
  return pathName.substr(0, pathName.length - 4).replace(/\//g, ".");
}

function elmModuleToPath(moduleName){
  return moduleName.replace(/\./g, "/") + ".elm";
}

module.exports = {
  RUNNING_MODE: RUNNING_MODE,
  init: init
};
