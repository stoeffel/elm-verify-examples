module DocTest.Parser
    exposing
        ( parse
        , parseImports
        , parseComments
        )

import String
import Regex exposing (..)
import List.Extra
import DocTest.Types exposing (..)


parse : String -> TestSuite
parse str =
    { imports = parseImports str
    , tests =
        str
            |> parseComments
            |> List.Extra.groupWhile (\x y -> not <| assertionPrefix y)
            |> List.map (toTest ( [], [] ) "")
    }


toTest : ( List String, List String ) -> String -> List String -> Test
toTest ( assertion, expectation ) last str =
    case str of
        h :: rest ->
            if assertionPrefix h then
                toTest ( h :: assertion, expectation ) h rest
            else if expectationPrefix h then
                toTest ( assertion, h :: expectation ) h rest
            else if assertionPrefix last then
                toTest ( h :: assertion, expectation ) last rest
            else
                toTest ( assertion, h :: expectation ) last rest

        _ ->
            let
                clean x =
                    List.map replacePrefix x
                        |> List.reverse
                        |> String.join " "
            in
                Test (clean assertion) (clean expectation)


parseImports : String -> List String
parseImports str =
    str
        |> String.lines
        |> List.foldl parseImport []
        |> List.reverse


parseImport : String -> List String -> List String
parseImport str acc =
    if contains (regex "^import\\s.*") str then
        str :: acc
    else
        acc


parseComments : String -> List String
parseComments str =
    str
        |> String.lines
        |> parseComments_ True []
        |> List.reverse


parseComments_ : Bool -> List String -> List String -> List String
parseComments_ notInComment acc str =
    case str of
        h :: t ->
            if notInComment then
                parseComments_ (commentBegin h) acc t
            else if isDocTestPrefix h then
                parseComments_ (commentEnd h) (h :: acc) t
            else
                parseComments_ (commentEnd h) acc t

        _ ->
            acc


commentBegin : String -> Bool
commentBegin str =
    contains (regex "^{-") str


commentEnd : String -> Bool
commentEnd str =
    contains (regex "^-}") str


replacePrefix : String -> String
replacePrefix str =
    replace (AtMost 1) (regex "\\s{4}[>|=|\\.]{3}\\s") (\_ -> "") str


isDocTestPrefix : String -> Bool
isDocTestPrefix str =
    expectationPrefix str
        || assertionPrefix str
        || continuationPrefix str


expectationPrefix : String -> Bool
expectationPrefix str =
    contains (regex "\\s{4}===\\s.*") str


continuationPrefix : String -> Bool
continuationPrefix str =
    contains (regex "\\s{4}\\.\\.\\.\\s.*") str


assertionPrefix : String -> Bool
assertionPrefix str =
    contains (regex "\\s{4}>>>\\s.*") str
