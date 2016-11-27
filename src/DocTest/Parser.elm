module DocTest.Parser exposing (parse)

import DocTest.Types exposing (..)
import List.Extra
import Regex exposing (Regex, HowMany(..))
import String


parse : String -> TestSuite
parse str =
    { imports = parseImports str
    , tests =
        parseComments str
            |> List.concatMap (filterNotDocTest << List.filterMap parseDocTest << String.lines)
            |> List.Extra.groupWhile (\x y -> not <| isAssertion y)
            |> List.filterMap toTest
    }


parseImports : String -> List String
parseImports str =
    Regex.find All importRegex str
        |> List.map .match


parseComments : String -> List String
parseComments str =
    Regex.find All commentRegex str
        |> List.map .match


parseDocTest : String -> Maybe Syntax
parseDocTest =
    oneOf
        [ choice assertionRegex Assertion
        , choice continuationRegex Continuation
        , choice expectationRegex Expectation
        ]


importRegex : Regex
importRegex =
    Regex.regex "import\\s.*"


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


choice : Regex -> (String -> Syntax) -> (String -> Maybe Syntax)
choice regex e str =
    Regex.find (AtMost 1) regex str
        |> List.map .submatches
        |> List.concat
        |> List.filterMap identity
        |> List.head
        |> Maybe.map e


filterNotDocTest : List Syntax -> List Syntax
filterNotDocTest xs =
    if List.isEmpty <| List.filter isAssertion xs then
        []
    else
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


isAssertion : Syntax -> Bool
isAssertion e =
    case e of
        Assertion str ->
            True

        _ ->
            False
