module DocTest.Parser exposing (parse)

import DocTest.Types exposing (..)
import List.Extra
import Regex exposing (Regex, HowMany(..))
import String


parse : String -> TestSuite
parse str =
    let
        ( imports, tests ) =
            parseComments str
                |> List.concatMap (filterNotDocTest << parseDocTests << String.lines << .match)
                |> List.partition isImport
    in
        { imports = List.map toStr imports
        , tests =
            tests
                |> List.Extra.groupWhile (\x y -> not <| isAssertion y)
                |> List.filterMap toTest
        }


parseComments : String -> List Regex.Match
parseComments str =
    Regex.find All commentRegex str


parseDocTests : List String -> List Syntax
parseDocTests =
    List.filterMap <|
        oneOf
            [ makeSyntaxRegex importRegex Import
            , makeSyntaxRegex assertionRegex Assertion
            , makeSyntaxRegex continuationRegex Continuation
            , makeSyntaxRegex expectationRegex Expectation
            ]


importRegex : Regex
importRegex =
    Regex.regex "^\\s{4}>>>\\s(import\\s.*)"


commentRegex : Regex
commentRegex =
    Regex.regex "{-[^]*?-}"


assertionRegex : Regex
assertionRegex =
    Regex.regex "^\\s{4}>>>\\s(.*)"


continuationRegex : Regex
continuationRegex =
    Regex.regex "^\\s{4}\\.\\.\\.\\s(.*)"


expectationRegex : Regex
expectationRegex =
    Regex.regex "^\\s{4}(.*)"


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
    case List.filter (\x -> isImport x || isAssertion x) xs of
        [] ->
            []

        _ ->
            xs


toTest : List Syntax -> Maybe Test
toTest e =
    let
        ( assertion, expectation ) =
            List.partition (not << isExpectiation) e
                |> Tuple.mapFirst (List.map toStr)
                |> Tuple.mapSecond (List.map toStr)
    in
        if List.isEmpty assertion || List.isEmpty expectation then
            Nothing
        else
            Just <| Test (String.join " " assertion) (String.join " " expectation)


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
