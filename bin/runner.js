// imports
var path = require('path');
var mkdirp = require("mkdirp");
var fs = require("fs");
var Elm = require("./elm.js");
var helpers = require('./cli-helpers.js');
var rimraf = require('rimraf');
var childProcess = require('child_process');


// loaders are called by init
var model = function(options){
  var verifyExamplesConfig = helpers.loadVerifyExamplesConfig(options.configPath);
  verifyExamplesConfig.testsPath = path.join(
    process.cwd(),
    options.output
  );
  var config = forFiles(verifyExamplesConfig, options.forFiles);

  return {
    config: config,
    run: generate,
    showWarnings: options.showWarnings,
    output: options.output,
    elmTestPath: options.elmTestPath,
    configPath: options.configPath,
    cleanup: cleanup,
    runElmTest: runElmTest,
    testsDocPath: path.join(options.output, "VerifyExamples")
  };
};


// parse args
function init(argv){
  var configJson = "elm-verify-examples.json";
  var defaultConfigPath = path.join(process.cwd(), 'tests', configJson);

  var options = {
    showWarnings: true,
    output: "tests",
    configPath: defaultConfigPath,
    forFiles: undefined,
    elmTestPath: path.join(__dirname, '../node_modules/.bin/elm-test')
  };

  if (typeof argv.warn !== "undefined") {
    options.showWarnings = argv.warn;
  }

  if (typeof argv.output !== "undefined") {
    options.output = argv.output;
    options.configPath = path.join(process.cwd(), options.output, configJson);
  }

  if (typeof argv.config !== "undefined") {
    options.configPath = argv.config;
  }

  if (typeof argv.elmTest !== "undefined") {
    options.elmTestPath = argv.elmTest;
  }

  if (typeof argv._ !== "undefined" && argv._.length > 0) {
    options.forFiles = argv._;
  }

  if (options.showWarnings) console.log('Running in generate mode..');
  return model(options);
}

function generate(model, allTestsGenerated) {
  var config = model.config;
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
      config.testsPath,
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

function runElmTest(model){
  var elmTest = "elm-test";
  if (fs.existsSync(model.elmTestPath)) {
    elmTest = model.elmTestPath;
  }
  if (typeof model.config.elmTest !== "undefined") {
    var configuredPath = path.resolve(path.join(model.config.testsPath, model.config.elmTest));
    if (fs.existsSync(configuredPath)) {
      elmTest = configuredPath;
    }
  }

  return childProcess.spawnSync(elmTest, [model.testsDocPath],
    {
      cwd: process.cwd(),
      stdio: 'inherit'
    }).status;
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
  ).map(elmPathToModule(config.root, config.testsPath));

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

function elmPathToModule(root, testsPath) {
  return function(pathName){
    var relativePath = path.relative(path.resolve(path.join(testsPath, root)), pathName);
    if (relativePath.startsWith("./")) {
      relativePath = relativePath.substr(2);
    }
    return relativePath
      .substr(0, relativePath.length - 4)
      .replace(/\//g, ".");
  };
}

function elmModuleToPath(moduleName){
  return moduleName.replace(/\./g, "/") + ".elm";
}

module.exports = {
  init: init
};
