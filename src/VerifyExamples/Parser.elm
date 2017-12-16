module VerifyExamples.Parser exposing (parse)

import VerifyExamples.Ast as Ast exposing (Ast)
import VerifyExamples.Comment as Comment exposing (Comment)
import VerifyExamples.IntermediateAst as IntermediateAst exposing (IntermediateAst)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)


parse : String -> List TestSuite
parse =
    Comment.parse
        >> List.map toTestSuite
        >> TestSuite.group


toTestSuite : Comment -> TestSuite
toTestSuite { comment, functionName } =
    comment
        |> IntermediateAst.fromString
        |> Ast.fromIntermediateAst
        |> TestSuite.fromAst functionName
