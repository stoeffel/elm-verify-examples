module DocTest.Parser exposing (parse)

import DocTest.Types exposing (..)
import List.Extra
import Regex exposing (HowMany(..), Regex)
import String


parse : String -> List TestSuite
parse str =
    str
        |> parseComments
        |> List.map
            (\parsedComment ->
                let
                    maybeFunctionName =
                        case parsedComment.submatches of
                            _ :: name :: _ ->
                                Maybe.andThen findFunctionName name

                            _ ->
                                Nothing
                in
                parsedComment
                    |> .match
                    |> String.lines
                    |> List.concatMap splitOneLiners
                    |> parseDocTests
                    |> List.partition isImport
                    |> toTestSuite maybeFunctionName
            )


toTestSuite : Maybe String -> ( List Syntax, List Syntax ) -> TestSuite
toTestSuite maybeFunctionName ( imports, tests ) =
    { imports = List.map toStr imports
    , tests =
        tests
            |> List.filter (not << isLocalFunction)
            |> List.Extra.groupWhile (\x y -> not <| isAssertion y)
            |> List.map filterNotDocTest
            |> List.filterMap toTest
    , functionName = maybeFunctionName
    , functions =
        tests
            |> List.filter isLocalFunction
            |> List.filter (isUsed <| List.filter (not << isLocalFunction) tests)
            |> List.map toStr
    }


splitOneLiners : String -> List String
splitOneLiners str =
    str
        |> Regex.replace All
            (Regex.regex "\\s\\-\\->\\s")
            (\_ -> "\n    --> ")
        |> String.lines


parseComments : String -> List Regex.Match
parseComments str =
    Regex.find All commentRegex str


parseDocTests : List String -> List Syntax
parseDocTests lines =
    let
        collapseLines : List Syntax -> List Syntax -> List Syntax
        collapseLines acc xs =
            case ( acc, xs ) of
                ( (Assertion a) :: rest1, (Assertion b) :: rest2 ) ->
                    collapseLines (Assertion (a ++ b) :: rest1) rest2

                ( (LocalFunction a) :: rest1, (Assertion b) :: rest2 ) ->
                    collapseLines (LocalFunction (a ++ "\n" ++ b) :: rest1) rest2

                ( a :: _, b :: rest2 ) ->
                    collapseLines (b :: acc) rest2

                ( [], b :: rest2 ) ->
                    collapseLines [ b ] rest2

                ( _, [] ) ->
                    acc
    in
    lines
        |> List.filterMap
            (oneOf
                [ makeSyntaxRegex newLineRegex (\_ -> NewLine)
                , makeSyntaxRegex importRegex Import
                , makeSyntaxRegex expectationRegex Expectation
                , makeSyntaxRegex continuationRegex Continuation
                , makeSyntaxRegex localFunctionRegex LocalFunction
                , makeSyntaxRegex assertionRegex Assertion
                ]
            )
        |> collapseLines []
        |> List.reverse


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
    Regex.regex "({-[^]*?-})(\n[^\n]*)"


assertionRegex : Regex
assertionRegex =
    Regex.regex "^\\s{4}(.*)"


continuationRegex : Regex
continuationRegex =
    Regex.regex "^\\s{4}\\-\\-\\-\\s(.*)"


expectationRegex : Regex
expectationRegex =
    Regex.regex "^\\s{4}\\-\\->\\s(.*)"


localFunctionRegex : Regex
localFunctionRegex =
    Regex.regex "^\\s{4}(\\w+\\s:\\s.*)"


oneOf : List (String -> Maybe Syntax) -> String -> Maybe Syntax
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


makeSyntaxRegex : Regex -> (String -> Syntax) -> (String -> Maybe Syntax)
makeSyntaxRegex regex e str =
    Regex.find (AtMost 1) regex str
        |> List.map .submatches
        |> List.concat
        |> List.filterMap identity
        |> List.head
        |> Maybe.map e


filterNotDocTest : List Syntax -> List Syntax
filterNotDocTest xs =
    case List.filter (\x -> isImport x || isExpectiation x) xs of
        [] ->
            []

        _ ->
            xs


toTest : List Syntax -> Maybe Test
toTest e =
    let
        ( assertion, expectation ) =
            List.partition isAssertion e
                |> Tuple.mapFirst (List.map toStr)
                |> Tuple.mapSecond (List.map toStr)
    in
    if List.isEmpty assertion || List.isEmpty expectation then
        Nothing
    else
        Test (String.join " " assertion) (String.join " " expectation)
            |> Just


isExpectiation : Syntax -> Bool
isExpectiation e =
    case e of
        Expectation str ->
            True

        _ ->
            False


toStr : Syntax -> String
toStr e =
    case e of
        Assertion str ->
            str

        Continuation str ->
            str

        Expectation str ->
            str

        Import str ->
            str

        LocalFunction str ->
            str

        NewLine ->
            ""


isNewLine : Syntax -> Bool
isNewLine e =
    case e of
        NewLine ->
            True

        _ ->
            False


isAssertion : Syntax -> Bool
isAssertion e =
    case e of
        Assertion str ->
            True

        _ ->
            False


isImport : Syntax -> Bool
isImport e =
    case e of
        Import str ->
            True

        _ ->
            False


isLocalFunction : Syntax -> Bool
isLocalFunction e =
    case e of
        LocalFunction str ->
            True

        _ ->
            False


isUsed : List Syntax -> Syntax -> Bool
isUsed xs x =
    findFunctionName (toStr x)
        |> Maybe.map
            (\fn ->
                List.any (toStr >> String.contains fn) xs
            )
        |> Maybe.withDefault False


findFunctionName : String -> Maybe String
findFunctionName str =
    str
        |> Regex.find (AtMost 1) functionNameRegex
        |> List.head
        |> Maybe.andThen (.submatches >> List.head)
        |> Maybe.andThen identity
