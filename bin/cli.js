#!/usr/bin/env node

var processTitle = "elm-verify-examples";

process.title = processTitle;

var argv = require('yargs').argv;
var init = require('./runner').init;
var childProcess = require('child_process');
var path = require('path');


// stateful things
var cliModel = init(argv);

cliModel.run(cliModel, function() {
  var exit = childProcess.spawnSync(path.join(__dirname, '../node_modules/.bin/elm-test'),
    {
      cwd: process.cwd(),
      stdio: 'inherit'
    });
  cliModel.cleanup(cliModel);
  process.exit(exit.status);
});
