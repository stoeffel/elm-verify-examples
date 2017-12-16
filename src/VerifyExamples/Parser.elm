module VerifyExamples.Parser exposing (parse)

import List.Extra
import Regex exposing (HowMany(..), Regex)
import String
import VerifyExamples.Ast as Ast exposing (Ast)
import VerifyExamples.Function as Function exposing (Function)
import VerifyExamples.IntermediateAst as IntermediateAst exposing (IntermediateAst)
import VerifyExamples.Test exposing (Test)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)


parse : String -> List TestSuite
parse =
    parseComments
        >> List.map toTestSuite
        >> TestSuite.group


toTestSuite : { comment : String, functionName : String } -> TestSuite
toTestSuite { comment, functionName } =
    comment
        |> IntermediateAst.fromString
        |> Ast.fromIntermediateAst
        |> TestSuite.fromAst functionName


parseComments : String -> List { comment : String, functionName : String }
parseComments =
    List.filterMap (nameAndComment << .submatches)
        << Regex.find All commentRegex


nameAndComment : List (Maybe String) -> Maybe { comment : String, functionName : String }
nameAndComment matches =
    case matches of
        (Just comment) :: (Just functionName) :: _ ->
            Just
                { comment = comment
                , functionName =
                    functionName
                        |> String.split " :"
                        |> List.head
                        |> Maybe.withDefault ""
                }

        _ ->
            Nothing


commentRegex : Regex
commentRegex =
    Regex.regex "({-[^]*?-})\x0D?\n([^\x0D\n]*)\\s[:=]"
