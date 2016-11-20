// imports
var path = require('path');
var mkdirp = require("mkdirp");
var fs = require("fs");
var Elm = require("./elm.js");
var helpers = require('./cli-helpers.js');


var RUNNING_MODE = {
  GENERATE: 0,
  RUN: 1
};

var running_mode_runners = {
  RUNNING_MODE.GENERATE: generate,
  RUNNING_MODE.RUN: function() { console.log("dey see me running"); }
};


/* Running modes currently supported are either
   - generate, to generate tests as part of your suite
   - run, to run a single file, provide the file name
*/
var running_mode_loaders = {
  RUNNING_MODE.GENERATE: function(){
    var docTestConfig = helpers.loadDocTestConfig();

    return {
      runningMode: RUNNING_MODE.GENERATE,
      config: docTestConfig,
      run: running_mode_runners[RUNNING_MODE.RUN]
    };
  },
  RUNNING_MODE.RUN: function(argv){
    var files = argv.run;

    var config = {
      files: files
    };

    return {
      runningMode: RUNNING_MODE.RUN,
      config: config,
      run: running_mode_runners[RUNNING_MODE.RUN]
    };
  }
};


// parse args
function init(argv){
  var model = null;

  if (typeof argv.run === "undefined") {
    console.log('Running in generate mode..');
    model = running_mode_loaders[RUNNING_MODE.GENERATE]();
  } else {
    console.log('Running in run mode..')
    model = running_mode_loaders[RUNNING_MODE.RUN](argv);
  }

  return model;
}


function generate(config) {
  var testsPath = path.join(
    process.cwd(),
    "tests"
  );
  var testsDocPath = path.join(
    testsPath,
    "Doc"
  );


  helpers.createDocTest(testsDocPath, config.docTests.tests, function() {
    var app = Elm.DocTest.worker(config.docTests);

    app.ports.readFile.subscribe(function(test) {
      var pathToModule = path.join(
        testsPath,
        config.docTests.root,
        test.replace(/\./g, "/") + ".elm"
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
        app.ports.fileRead.send([test, data]);
      });
    });

    app.ports.writeFile.subscribe(function(data) {
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
        });
      });
    });
  });
}


module.exports = {
  RUNNING_MODE: RUNNING_MODE,
  init: init
}
