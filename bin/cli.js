#!/usr/bin/env node

var processTitle = "elm-doc-test";

process.title = processTitle;

var argv = require('yargs').argv;
var init = require('./modes').init;


// stateful things
var cliModel = init(argv);

cliModel.run(cliModel);
