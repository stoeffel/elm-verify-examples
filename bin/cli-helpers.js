var path = require("path");
var fsExtra = require("fs-extra");
const { globSync } = require("glob");

function loadVerifyExamplesConfig(configPath) {
  /* load the doc test config if we can find it
     otherwise, copy the template one and load that
  */

  var verifyExamples = null;
  var elmJson = null;

  try {
    verifyExamples = require(configPath);
    if (verifyExamples["root"] !== undefined) {
      console.warn(
        "elm-verify-examples.json: 'root' is no longer a valid key. It defaults to point one directory up from `/tests`."
      );
    }
    var elmJsonPath = findParentElmJson(path.dirname(configPath));
    elmJson = require(elmJsonPath);
  } catch (e) {
    var elmJsonPath = findParentElmJson(path.dirname(configPath));
    elmJson = require(elmJsonPath);
    verifyExamples = { tests: "all" };
  }

  return resolveTests(configPath, Object.assign({}, verifyExamples, elmJson));
}

function resolveTests(configPath, config) {
  if (config.tests === "exposed" || config.tests.includes("exposed")) {
    if (config.type == "package") {
      config.tests = config["exposed-modules"].concat("./README.md");
    } else {
      console.error(
        "Config asks for 'exposed', but elm.json type is not 'package'"
      );
      process.exit(1);
    }
  }
  if (config.tests === "all" || config.tests.includes("all")) {
    var allElmFiles = (config["source-directories"] ?? ["./src"])
      .map((d) =>
        globSync("**/*.elm", {
          cwd: path.join(path.dirname(configPath), "..", d),
        })
      )
      .flat()
      .map(elmPathToModuleName);
    config.tests = allElmFiles.concat("./README.md");
  }
  return config;
}

function findParentElmJson(p) {
  if (fsExtra.pathExistsSync(path.join(p, "elm.json"))) {
    return path.join(p, "elm.json");
  } else if (path.dirname(p) === p) {
    console.error("Config asks for 'exposed', but could not find elm.json");
    process.exit(1);
  } else {
    return findParentElmJson(path.dirname(p));
  }
}

function elmPathToModuleName(pathName) {
  return pathName.slice(0, -4).split(path.sep).join(".");
}

module.exports = {
  loadVerifyExamplesConfig: loadVerifyExamplesConfig,
};
