#!/usr/bin/env node

var processTitle = "elm-verify-examples";

process.title = processTitle;

var argv = require('yargs').argv;
var fs = require('fs');
var init = require('./runner').init;
var childProcess = require('child_process');
var path = require('path');


// stateful things
var cliModel = init(argv);

cliModel.run(cliModel, function() {
  var status = runElmTest();
  cliModel.cleanup(cliModel);
  process.exit(status);
});

function runElmTest(){
  var elmTest = "elm-test";
  var localElmTest = path.join(__dirname, '../node_modules/.bin/elm-test');
  if (fs.existsSync(localElmTest)) {
    elmTest = localElmTest;
  }

  return childProcess.spawnSync(elmTest,
    {
      cwd: process.cwd(),
      stdio: 'inherit'
    }).status;
}
