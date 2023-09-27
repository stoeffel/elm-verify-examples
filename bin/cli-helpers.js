var path = require("path");
var fsExtra = require("fs-extra");

function loadVerifyExamplesConfig(configPath) {
  /* load the doc test config if we can find it
     otherwise, copy the template one and load that
  */

  var verifyExamples = null;

  try {
    verifyExamples = require(configPath);
  } catch (e) {
    console.log(`Copying initial elm-verify-examples.json to ${configPath}`);
    fsExtra.copySync(
      path.resolve(__dirname, "./templates/elm-verify-examples.json"),
      configPath
    );

    verifyExamples = require(path.resolve(
      __dirname,
      "templates/elm-verify-examples.json"
    ));
  }

  return resolveTests(configPath, verifyExamples);
}

function resolveTests(configPath, config) {
  if (config.tests === "exposed") {
    /* This is asserting that we want to run for all exposed modules in a package
     */
    var elmJson = null;
    var elmJsonPath = findParentElmJson(path.dirname(configPath));
    try {
      elmJson = require(elmJsonPath);
    } catch (e) {
      console.error(
        "Config asks for 'exposed', but could not find elm.json at " +
          elmJsonPath
      );
      process.exit(1);
    }
    if (elmJson.type == "package") {
      config.tests = elmJson["exposed-modules"];
    } else {
      console.error(
        "Config asks for 'exposed', but elm.json type is not 'package'"
      );
      process.exit(1);
    }
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

module.exports = {
  loadVerifyExamplesConfig: loadVerifyExamplesConfig,
};
