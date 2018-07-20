module VerifyExamples.Parser exposing (parse)

import VerifyExamples.Ast.Grouped as GroupedAst exposing (GroupedAst)
import VerifyExamples.Ast.Intermediate as IntermediateAst exposing (IntermediateAst)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)


parse : { snippet : String, functionName : Maybe String } -> TestSuite
parse { snippet, functionName } =
    snippet
        |> IntermediateAst.fromString
        |> IntermediateAst.toAst
        |> GroupedAst.fromAst
        |> TestSuite.fromAst functionName
