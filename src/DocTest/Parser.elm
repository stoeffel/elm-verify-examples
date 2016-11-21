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
            else if continuationPrefix h then
                toTest ( h :: assertion, expectation ) h rest
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
        |> List.filter (not << String.isEmpty)
        |> List.reverse


parseComments_ : Bool -> List String -> List String -> List String
parseComments_ notInComment acc str =
    case str of
        h :: t ->
            if notInComment then
                parseComments_ (not <| commentBegin h) acc t
            else if commentEnd h then
                parseComments_ True acc t
            else
                parseComments_ notInComment (h :: acc) t

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
    str
        |> replace (AtMost 1) (regex "^\\s{4}") (\_ -> "")
        |> replace (AtMost 1) (regex "^[>|\\.]{3}\\s") (\_ -> "")


continuationPrefix : String -> Bool
continuationPrefix str =
    contains (regex "^\\s{4}\\.\\.\\.\\s.*") str


assertionPrefix : String -> Bool
assertionPrefix str =
    contains (regex "^\\s{4}>>>\\s.*") str
