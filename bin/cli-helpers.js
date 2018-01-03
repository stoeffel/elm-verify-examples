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
      path.resolve(__dirname, './templates/elm-verify-examples.json'),
      configPath
    );

    verifyExamples = require(path.resolve(__dirname, 'templates/elm-verify-examples.json'));
  }

  return verifyExamples;
}

module.exports =  {
    loadVerifyExamplesConfig: loadVerifyExamplesConfig
};
