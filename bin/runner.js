// imports
var path = require('path');
var mkdirp = require("mkdirp");
var fs = require("fs");
var Elm = require("./elm.js");
var helpers = require('./cli-helpers.js');
var rimraf = require('rimraf');


// loaders are called by init
var model = function(options){
  var verifyExamplesConfig = helpers.loadVerifyExamplesConfig(options.configPath);
  var config = forFiles(verifyExamplesConfig, options.forFiles);

  return {
    config: config,
    run: generate,
    showWarnings: options.showWarnings,
    output: options.output,
    configPath: options.configPath,
    cleanup: cleanup,
    testsDocPath: path.join(options.output, "VerifyExamples")
  };
};


// parse args
function init(argv){
  var defaultConfigPath = path.join(process.cwd(), 'tests/elm-verify-examples.json');

  var options = {
    showWarnings: true,
    output: "tests",
    configPath: defaultConfigPath,
    forFiles: undefined
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

  if (typeof argv._ !== "undefined" && argv._.length > 0) {
    options.forFiles = argv._;
  }

  if (options.showWarnings) console.log('Running in generate mode..');
  return model(options);
}

function generate(model, allTestsGenerated) {
  var config = model.config;
  var testsPath = path.join(
    process.cwd(),
    "tests"
  );
  cleanup(model);

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
    serial(data, writeFile(model.testsDocPath), function() {
        writtenTests = writtenTests + 1;
        if (writtenTests === config.tests.length && allTestsGenerated) {
          allTestsGenerated();
        }
    });
  });
}

function cleanup(model) {
  rimraf.sync(model.testsDocPath);
}

function forFiles(config, files){
  if (typeof files === "undefined") {
    return config;
  }

  config.tests = files.filter(
    function(v){ return v.endsWith('.elm'); }
  ).map(elmPathToModule);

  return config;
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
        path.join(testsDocModulePath, moduleName + ".elm"),
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
  if (pathName.startsWith("./")) {
    pathName = pathName.substr(2);
  }
  return pathName.substr(0, pathName.length - 4).replace(/\//g, ".");
}

function elmModuleToPath(moduleName){
  return moduleName.replace(/\./g, "/") + ".elm";
}

module.exports = {
  init: init
};
