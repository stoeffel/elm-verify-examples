module DocTest.Parser exposing (parse)

import DocTest.Types exposing (..)
import List.Extra
import Regex exposing (HowMany(..), Regex)
import String


parse : String -> TestSuite
parse str =
    let
        ( imports, tests ) =
            parseComments str
                |> List.concatMap (parseDocTests << List.concatMap splitOneLiners << String.lines << .match)
                |> List.partition isImport
    in
    { imports = List.map toStr imports
    , tests =
        tests
            |> List.foldr collapseAssertions []
            |> List.Extra.groupWhile (\x y -> not <| isAssertion y)
            |> List.map filterNotDocTest
            |> List.filterMap toTest
    }


splitOneLiners : String -> List String
splitOneLiners str =
    str
        |> Regex.replace Regex.All
            (Regex.regex "\\s\\-\\->\\s")
            (\_ -> "\n    --> ")
        |> String.lines


parseComments : String -> List Regex.Match
parseComments str =
    Regex.find All commentRegex str


parseDocTests : List String -> List Syntax
parseDocTests =
    List.filterMap <|
        oneOf
            [ makeSyntaxRegex newLineRegex (\_ -> NewLine)
            , makeSyntaxRegex importRegex Import
            , makeSyntaxRegex expectationRegex Expectation
            , makeSyntaxRegex continuationRegex Continuation
            , makeSyntaxRegex assertionRegex Assertion
            ]


newLineRegex : Regex
newLineRegex =
    Regex.regex "(^\\s*$)"


importRegex : Regex
importRegex =
    Regex.regex "^\\s{4}(import\\s.*)"


commentRegex : Regex
commentRegex =
    Regex.regex "{-[^]*?-}"


assertionRegex : Regex
assertionRegex =
    Regex.regex "^\\s{4}(.*)"


continuationRegex : Regex
continuationRegex =
    Regex.regex "^\\s{4}\\-\\-\\-\\s(.*)"


expectationRegex : Regex
expectationRegex =
    Regex.regex "^\\s{4}\\-\\->\\s(.*)"


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


collapseAssertions : Syntax -> List Syntax -> List Syntax
collapseAssertions x xs =
    case xs of
        [] ->
            [ x ]

        y :: rest ->
            if isAssertion x && isAssertion y then
                Assertion (toStr x ++ toStr y) :: rest
            else
                x :: xs
