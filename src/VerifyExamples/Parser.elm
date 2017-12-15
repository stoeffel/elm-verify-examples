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
parse str =
    str
        |> parseComments
        |> List.map
            (\( comment, fnName ) ->
                comment
                    |> IntermediateAst.fromString
                    |> Ast.fromIntermediateAst
                    |> TestSuite.fromAst fnName
            )
        |> TestSuite.group


parseComments : String -> List ( String, String )
parseComments str =
    let
        nameAndComment matches =
            case matches of
                comment :: name :: _ ->
                    Just
                        ( comment
                            |> Maybe.withDefault ""
                        , name
                            |> Maybe.map (String.split " :")
                            |> Maybe.andThen List.head
                            |> Maybe.withDefault ""
                        )

                _ ->
                    Nothing
    in
    Regex.find All commentRegex str
        |> List.map .submatches
        |> List.filterMap nameAndComment


commentRegex : Regex
commentRegex =
    Regex.regex "({-[^]*?-})\n([^\n]*)\\s[:=]"
