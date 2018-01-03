#!/usr/bin/env node

var processTitle = "elm-verify-examples";

process.title = processTitle;

var init = require('./runner').init;
var path = require('path');
var argv = require('yargs')
  .usage('Usage: $0 [modulePaths] [options]')
  .alias("w", "warn")
  .describe("warn", "Display warnings.")
  .default("warn", true)
  .alias("o", "output")
  .describe("output", "Change path to the generated tests.")
  .default("output", "tests")
  .describe("elm-test", "Path to elm-test.")
  .default("elm-test", path.join(__dirname, '../node_modules/.bin/elm-test'))
  .describe("elm-test-args", "Pass arguments to elm-test. f.e. `--elm-test-args=\"--report=junit\"`")
  .coerce("elm-test-args", function(arg) {
    if (typeof arg === "string") return arg.split(" ");
    return [];
  })
  .default("elm-test-args", [])
  .argv;


// stateful things
var cliModel = init(argv);

cliModel.run(cliModel, function() {
  var status = cliModel.runElmTest(cliModel);
  if (status === 0) cliModel.cleanup(cliModel);
  process.exit(status);
});
