// imports
var path = require("path");
var mkdirp = require("mkdirp");
var fs = require("fs");
var Elm = require("./elm.js");
var helpers = require("./cli-helpers.js");
var rimraf = require("rimraf");
var childProcess = require("child_process");
var chalk = require("chalk");

// loaders are called by init
var init = function(args) {
  var configJson = "elm-verify-examples.json";
  var configPath = path.join(process.cwd(), args.output, configJson);
  var verifyExamplesConfig = helpers.loadVerifyExamplesConfig(configPath);
  verifyExamplesConfig.testsPath = path.join(process.cwd(), args.output);
  var config = forFiles(verifyExamplesConfig, args._);

  return Object.assign(args, config, {
    testsDocPath: path.join(args.output, "VerifyExamples")
  });
};

function generate(model, allTestsGenerated) {
  if (model.warn) console.warn("Generate tests from examples...");
  cleanup(model);

  if (model.tests.length === 0) {
    if (model.warn) {
      warn(
        "No tests listed! Modify your elm-verify-examples.json file to include modules"
      );
      if (model.failOnWarn) process.exit(1);
    }
    return;
  }

  var app = Elm.Elm.VerifyExamples.init({ flags: model });
  app.ports.reportError.subscribe(function(err) {
    console.error(err);
    process.exit(1);
  });

  app.ports.readFile.subscribe(function(inputName) {
    if (path.extname(inputName) === ".md") {
      readSource(inputName, function(fileText) {
        app.ports.generateMarkdownVerifyExamples.send({
          fileName: cleanMarkdownPath(inputName),
          fileText: fileText
        });
      });
    } else {
      var pathToModule = path.join(
        model.testsPath,
        model.root,
        elmModuleToPath(inputName)
      );

      readSource(pathToModule, function(fileText) {
        app.ports.generateModuleVerifyExamples.send({
          moduleName: inputName,
          fileText: fileText,
          ignoredWarnings: ignoredWarnings(model.ignoreWarnings, inputName)
        });
      });
    }
  });

  var warnings = [];
  app.ports.warn.subscribe(function(args) {
    if (args.warnings.length === 0) return;
    warnings.push(args);
  });

  var writtenTests = 0;
  app.ports.writeFiles.subscribe(function(data) {
    serial(data, writeFile(model.testsDocPath), function() {
      writtenTests = writtenTests + 1;
      if (writtenTests === model.tests.length && allTestsGenerated) {
        allTestsGenerated(warnings);
      }
    });
  });
}

function ignoredWarnings(ignores, moduleName) {
  if (typeof ignores === "undefined") return [];
  if (typeof ignores[moduleName] === "undefined") return [];
  return ignores[moduleName];
}

function runElmTest(model) {
  var elmTest = "elm-test";
  if (fs.existsSync(model.elmTest)) {
    elmTest = model.elmTest;
  }
  if (typeof model.elmTest !== "undefined") {
    var configuredPath = path.resolve(
      path.join(model.testsPath, model.elmTest)
    );
    if (fs.existsSync(configuredPath)) {
      elmTest = configuredPath;
    }
  }

  model.elmTestArgs.unshift(model.testsDocPath);
  return childProcess.spawnSync(elmTest, model.elmTestArgs, {
    cwd: process.cwd(),
    stdio: "inherit"
  }).status;
}

function cleanup(model) {
  rimraf.sync(model.testsDocPath);
}

function warnModule(model) {
  return function(warnings) {
    if (!model.warn || warnings.warnings.length === 0) return;
    warn(chalk.underline("Warnings in module " + warnings.moduleName));
    warn("\n");
    warn(warnings.warnings.map(indent).join("\n"));
    warn("\n");
  };
}

function warnSummary(model, warnings) {
  if (!model.warn) return;
  var count = warnings.reduce(function(acc, warning) {
    return warning.warnings.length + acc;
  }, 0);
  if (count > 0) {
    warn(chalk.underline("EXAMPLES VERIFIED WITH WARNINGS"));
    console.warn(chalk.dim("Warnings: ") + count);
    warn("\n");
  }

  if (model.failOnWarn) process.exit(1);
}

function warn(str) {
  console.warn(chalk.yellow(str));
}
function indent(str) {
  return "    " + str;
}

function forFiles(model, files) {
  if (typeof files === "undefined" || files.length === 0) {
    return model;
  }

  model.tests = files
    .filter(function(v) {
      return v.endsWith(".elm");
    })
    .map(elmPathToModule(model.root, model.testsPath));

  return model;
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
  return function(data, done) {
    var test = data.content;
    var parts = data.moduleName.split(".");
    var modulePath = [];
    var moduleName = ".";

    if (parts.length > 1) {
      modulePath = parts.slice(0, -1);
      moduleName = parts.slice(-1)[0];
    } else {
      moduleName = parts[0];
    }

    var testsDocModulePath = path.join(testsDocPath, modulePath.join("/"));

    mkdirp(testsDocModulePath, function(err) {
      if (err) {
        console.error(err);
        process.exit(1);
        return;
      }
      fs.writeFile(
        path.join(testsDocModulePath, moduleName + ".elm"),
        test,
        "utf8",
        function(err) {
          if (err) {
            console.error(err);
            process.exit(1);
            return;
          }

          done();
        }
      );
    });
  };
}

function elmPathToModule(root, testsPath) {
  return function(pathName) {
    var relativePath = path.relative(
      path.resolve(path.join(testsPath, root)),
      pathName
    );
    if (relativePath.startsWith("./")) {
      relativePath = relativePath.substr(2);
    }
    return relativePath.substr(0, relativePath.length - 4).replace(/\//g, ".");
  };
}

function elmModuleToPath(moduleName) {
  return moduleName.replace(/\./g, "/") + ".elm";
}

function readSource(filePath, onSuccess) {
  fs.readFile(filePath, "utf8", function(err, fileText) {
    if (err) {
      console.error(err);
      process.exit(1);
      return;
    }
    onSuccess(fileText);
  });
}

function cleanMarkdownPath(pathName) {
  var relativePath = path.relative(path.resolve(), pathName);
  if (relativePath.startsWith("./")) {
    relativePath = relativePath.substr(2);
  }
  return relativePath;
}

module.exports = {
  init: init,
  run: generate,
  cleanup: cleanup,
  warnModule: warnModule,
  warnSummary: warnSummary,
  runElmTest: runElmTest
};
