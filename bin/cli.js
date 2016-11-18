#!/usr/bin/env node

var processTitle = "elm-doc-test";

process.title = processTitle;

var path = require("path");
var mkdirp = require("mkdirp");
var fs = require("fs");
var fsExtra = require("fs-extra");
var Elm = require("./elm.js");
var docTests = require(process.cwd() + "/tests/elm-doc-test.json");

var testsPath = path.join(
  process.cwd(),
  "tests"
);
var testsDocPath = path.join(
  testsPath,
  "Doc"
);

createDocTest(docTests.tests, function() {
  var app = Elm.DocTest.worker(docTests);

  app.ports.readFile.subscribe(function(test) {
    var pathToModule = path.join(
      testsPath,
      docTests.root,
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

function createDocTest(tests, cb) {
  mkdirp(testsDocPath, function(err) {
    if (err) {
      console.error(err);
      process.exit(-1);
      return;
    }

    fsExtra.copySync(
      path.resolve(__dirname,'./templates/Main.elm'),
      path.join(testsDocPath, 'Main.elm')
    );
    fs.writeFile(
      path.join(testsDocPath, "Tests.elm"),
      testsFile(tests),
      "utf8",
      function(err) {
        if (err) {
          console.error(err);
          process.exit(-1);
          return;
        }
        cb();
    });
  });
}

function testsFile(tests) {
  var testsString = tests.map(function(test) {
    return "        Doc." + test + ".spec";
  });
  var imports = tests.map(function(test) {
    return "import Doc." + test;
  });
  return [
    "module Doc.Tests exposing (..)",
    "",
    "import Test exposing (..)",
    "import Expect",
    imports.join("\n"),
    "",
    "",
    "all : Test",
    "all =",
    "    describe \"DocTests\"",
    "    [\n", testsString.join(",\n") + "    ]"
  ].join("\n");
}
