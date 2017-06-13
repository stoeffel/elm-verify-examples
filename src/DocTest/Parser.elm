module DocTest.Parser exposing (parse)

import DocTest.Ast exposing (..)
import List.Extra
import Regex exposing (HowMany(..), Regex)
import String


parse : String -> List TestSuite
parse str =
    str
        |> parseComments
        |> List.map
            (\( comment, fnName ) ->
                comment
                    |> commentToIntermediateAst
                    |> intermediateAstToAst
                    |> astToTestSuite fnName
            )


astToTestSuite : String -> List Ast -> TestSuite
astToTestSuite fnName ast =
    let
        toTests : List Test -> List Ast -> List Test
        toTests acc xs =
            case xs of
                (Assertion x) :: (Assertion y) :: rest ->
                    toTests acc (Assertion y :: rest)

                (Assertion x) :: (Expectation y) :: rest ->
                    toTests
                        ({ assertion = x
                         , expectation = y
                         }
                            :: acc
                        )
                        rest

                _ ->
                    acc
    in
    { imports =
        List.filter isImport ast
            |> List.map astToString
    , tests =
        ast
            |> List.filter (\a -> isAssertion a || isExpectiation a)
            |> toTests []
            |> List.reverse
    , functionName = Just fnName
    , functions =
        ast
            |> List.filter isLocalFunction
            |> List.filterMap (astToFunction ast)
    }


parseComments : String -> List ( String, String )
parseComments str =
    let
        nameAndComment matches =
            case matches of
                comment :: name :: _ ->
                    Just ( Maybe.withDefault "" comment, Maybe.withDefault "" name )

                _ ->
                    Nothing
    in
    Regex.find All commentRegex str
        |> List.map .submatches
        |> List.filterMap nameAndComment


commentToIntermediateAst : String -> List IntermediateAst
commentToIntermediateAst parsedComment =
    commentLines parsedComment
        |> List.filterMap toIntermediateAst


commentLines : String -> List String
commentLines str =
    str
        |> String.lines
        |> List.concatMap splitOneLiners


splitOneLiners : String -> List String
splitOneLiners str =
    let
        breakIntoTwoLines a =
            if Regex.contains expectationRegex a then
                a
            else
                Regex.replace Regex.All arrowRegex (\_ -> "\n    --> ") a
    in
    str
        |> breakIntoTwoLines
        |> String.lines


toIntermediateAst : String -> Maybe IntermediateAst
toIntermediateAst =
    oneOf
        [ makeSyntaxRegex newLineRegex (\_ -> NewLine)
        , makeSyntaxRegex importRegex (Expression ImportPrefix)
        , makeSyntaxRegex expectationRegex (Expression ArrowPrefix)
        , makeSyntaxRegex localFunctionRegex toFunctionExpression
        , makeSyntaxRegex assertionRegex MaybeExpression
        ]


toFunctionExpression : String -> IntermediateAst
toFunctionExpression str =
    let
        functionName : String
        functionName =
            str
                |> Regex.find (AtMost 1) functionNameRegex
                |> List.head
                |> Maybe.andThen (.submatches >> List.head)
                |> Maybe.andThen identity
                |> Maybe.withDefault "no function name given!"
    in
    Func functionName str


intermediateAstToAst : List IntermediateAst -> List Ast
intermediateAstToAst xs =
    let
        groupToAst : List IntermediateAst -> Maybe Ast
        groupToAst xs =
            case xs of
                (MaybeExpression x) :: rest ->
                    Assertion (String.join "\n" <| x :: List.map intermediateToString rest)
                        |> Just

                (Expression ArrowPrefix x) :: rest ->
                    Expectation (String.join "\n" <| x :: List.map intermediateToString rest)
                        |> Just

                (Expression ImportPrefix x) :: rest ->
                    Import (String.join "\n" <| x :: List.map intermediateToString rest)
                        |> Just

                (Func name x) :: rest ->
                    LocalFunction name (String.join "\n" <| x :: List.map intermediateToString rest)
                        |> Just

                _ ->
                    Nothing

        groupBy : IntermediateAst -> IntermediateAst -> Bool
        groupBy x y =
            case ( x, y ) of
                ( _, NewLine ) ->
                    False

                ( NewLine, MaybeExpression _ ) ->
                    False

                ( _, MaybeExpression _ ) ->
                    True

                ( Expression ArrowPrefix _, Expression ArrowPrefix _ ) ->
                    True

                _ ->
                    False
    in
    xs
        |> List.Extra.groupWhileTransitively groupBy
        |> List.filterMap groupToAst


arrowRegex : Regex
arrowRegex =
    Regex.regex "\\s\\-\\->\\s"


newLineRegex : Regex
newLineRegex =
    Regex.regex "(^\\s*$)"


importRegex : Regex
importRegex =
    Regex.regex "^\\s{4}(import\\s.*)"


functionNameRegex : Regex
functionNameRegex =
    Regex.regex "(\\w+)\\s:"


commentRegex : Regex
commentRegex =
    Regex.regex "({-[^]*?-})\n([^\n]*)\\s[:=]"


assertionRegex : Regex
assertionRegex =
    Regex.regex "^\\s{4}(.*)"


expectationRegex : Regex
expectationRegex =
    Regex.regex "^\\s{4}\\-\\->\\s(.*)"


localFunctionRegex : Regex
localFunctionRegex =
    Regex.regex "^\\s{4}(\\w+\\s:\\s.*)"


oneOf : List (a -> Maybe b) -> a -> Maybe b
oneOf fs str =
    case fs of
        [] ->
            Nothing

        f :: rest ->
            case f str of
                Just result ->
                    Just result

                Nothing ->
                    oneOf rest str


makeSyntaxRegex : Regex -> (String -> a) -> (String -> Maybe a)
makeSyntaxRegex regex f str =
    Regex.find (AtMost 1) regex str
        |> List.map .submatches
        |> List.concat
        |> List.filterMap identity
        |> List.head
        |> Maybe.map f
