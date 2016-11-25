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
                toTest ( h :: assertion, expectation ) last rest
            else if assertionPrefix last then
                toTest ( assertion, h :: expectation ) last rest
            else
                toTest ( assertion, expectation ) "" rest

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
        |> parseComments_ True True []
        |> List.filter (not << String.isEmpty)
        |> List.reverse


parseComments_ : Bool -> Bool -> List String -> List String -> List String
parseComments_ notInComment notInTest acc str =
    case str of
        h :: t ->
            if notInComment then
                parseComments_ (not <| commentBegin h) True acc t
            else if commentEnd h then
                parseComments_ True True acc t
            else if assertionPrefix h then
                parseComments_ notInComment False (h :: acc) t
            else if not notInTest && contains fourSpaces h then
                parseComments_ notInComment False (h :: acc) t
            else
                parseComments_ notInComment True acc t

        _ ->
            acc


commentBegin : String -> Bool
commentBegin str =
    contains commentBeginToken str


commentBeginToken : Regex
commentBeginToken =
    regex "^{-"


commentEnd : String -> Bool
commentEnd str =
    contains commentEndToken str


commentEndToken : Regex
commentEndToken =
    regex "^-}"


replacePrefix : String -> String
replacePrefix =
    replace (AtMost 1) docTestPrefixes (\_ -> "")


docTestPrefixes : Regex
docTestPrefixes =
    regex "^\\s{4}[>|\\.]{3}\\s"


fourSpaces : Regex
fourSpaces =
    regex "^\\s{4}"


continuationPrefix : String -> Bool
continuationPrefix =
    contains continuationToken


continuationToken : Regex
continuationToken =
    regex "^\\s{4}\\.\\.\\.\\s.*"


assertionPrefix : String -> Bool
assertionPrefix =
    contains assertionToken


assertionToken : Regex
assertionToken =
    regex "^\\s{4}>>>\\s.*"
