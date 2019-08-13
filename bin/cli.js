#!/usr/bin/env node

var processTitle = "elm-verify-examples";

process.title = processTitle;

var runner = require("./runner");
var path = require("path");
var argv = require("yargs")
  .usage("Usage: $0 [modulePaths] [options]")
  .alias("w", "warn")
  .describe("warn", "Display warnings.")
  .boolean("warn")
  .describe("fail-on-warn", "Fail when there are warnings.")
  .boolean("fail-on-warn")
  .alias("o", "output")
  .describe("output", "Change path to the generated tests.")
  .default("output", "tests")
  .alias("r", "run-tests")
  .describe("run-tests", "Run generated tests using `elm-test`.")
  .boolean("run-tests")
  .describe("elm-test", "Path to elm-test.")
  .default("elm-test", path.join(__dirname, "../node_modules/.bin/elm-test"))
  .describe(
    "elm-test-args",
    'Pass arguments to elm-test. f.e. `--elm-test-args="--report=junit"`'
  )
  .coerce("elm-test-args", function(arg) {
    if (typeof arg === "string") return arg.split(" ");
    return [];
  })
  .default("elm-test-args", []).argv;

var model = runner.init(argv);

runner.run(model, function(warnings) {
  warnings.map(runner.warnModule(model));
  if (model["run-tests"]) {
    var status = runner.runElmTest(model);
    if (status === 0) runner.cleanup(model);
    runner.warnSummary(model, warnings);
    process.exit(status);
  } else {
    runner.warnSummary(model, warnings);
    process.exit(0);
  }
});
