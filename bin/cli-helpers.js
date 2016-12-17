var path = require("path");
var fs = require('fs');
var fsExtra = require("fs-extra");
var mkdirp = require("mkdirp");
var shell = require('shelljs');

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
    return "        Doc." + test.name + "Spec.spec";
  });
  var imports = tests.map(function(test) {
    return "import Doc." + test.name + "Spec";
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

function loadDocTestConfig(cb) {
  var root = process.cwd();
  shell.exec('elm-reflection --path ' + root + ' --filter DocTest', { silent: true }, function(code, out, err) {
    if (code === 0) {
      cb(JSON.parse(out));
    } else {
      console.error(err);
      process.exit(-1);
    }
  });
  // shell.exec('echo "[]" > ' + root + '/elm-doc-test_____.json');
  // console.log('elm-reflection --path ' + root + ' --filter DocTest > ' + root + '/elm-doc-test_____.json');
  // shell.exec('elm-reflection --path ' + root + ' --filter DocTest > ' + root + '/elm-doc-test_____.json');
  // var tests = require(path.join(root, 'elm-doc-test_____.json'));
  // shell.rm(root + '/elm-doc-test_____.json');
  // return tests;
}

module.exports =  {
    loadDocTestConfig: loadDocTestConfig,
    createDocTest: createDocTest
};
