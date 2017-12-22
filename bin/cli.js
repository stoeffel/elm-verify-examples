#!/usr/bin/env node

var processTitle = "elm-verify-examples";

process.title = processTitle;

var argv = require('yargs').argv;
var init = require('./runner').init;


// stateful things
var cliModel = init(argv);

cliModel.run(cliModel);
