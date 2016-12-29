var path = require("path");
var fs = require('fs');
var fsExtra = require("fs-extra");
var mkdirp = require("mkdirp");

function createDocTest(testsDocPath, tests, cb) {
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
    return "        Doc." + test + "Spec.spec";
  });
  var imports = tests.map(function(test) {
    return "import Doc." + test + "Spec";
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

function loadDocTestConfig(configPath=false) {
  /* load the doc test config if we can find it
     otherwise, copy the template one and load that
  */

  var docTests = null;
  if (!configPath) {
    configPath = path.join(process.cwd(), 'tests/elm-doc-test.json');
  }

  try {
    docTests = require(configPath);
  } catch (e) {
    console.log(`Copying initial elm-doc-test.json to ${configPath}`);
    fsExtra.copySync(
      path.resolve(__dirname, './templates/elm-doc-test.json'),
      configPath
    );

    docTests = require(path.resolve(__dirname, 'templates/elm-doc-test.json'));
  }

  return docTests;
}

module.exports =  {
    loadDocTestConfig: loadDocTestConfig,
    createDocTest: createDocTest
}
