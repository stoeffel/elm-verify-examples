var path = require("path");
var fs = require('fs');
var fsExtra = require("fs-extra");
var mkdirp = require("mkdirp");

function loadDocTestConfig(configPath) {
  /* load the doc test config if we can find it
     otherwise, copy the template one and load that
  */

  var docTests = null;

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
    loadDocTestConfig: loadDocTestConfig
}
