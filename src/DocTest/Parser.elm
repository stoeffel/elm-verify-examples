module DocTest.Parser exposing (parse)

import Combine exposing (..)
import Combine.Char exposing (..)
import DocTest.Types exposing (..)
import List.Extra
import Regex exposing (Regex, HowMany(..))
import String


type E
    = Assertion String
    | Continuation String
    | Expectation String


parseImports : String -> List String
parseImports str =
    Regex.find All importRegex str
        |> List.map .match


importRegex : Regex
importRegex =
    Regex.regex "import\\s.*"


parseComments : String -> List String
parseComments str =
    Regex.find All commentRegex str
        |> List.map .match


commentRegex : Regex
commentRegex =
    Regex.regex "{-[^-}]*-}"


docTest : Parser s (Maybe E)
docTest =
    choice
        [ Just << Assertion <$> (space *> space *> space *> space *> string ">>> " *> Combine.regex ".*")
        , Just << Continuation <$> (space *> space *> space *> space *> string "... " *> Combine.regex ".*")
        , Just << Expectation <$> (space *> space *> space *> space *> Combine.regex ".*")
        , Nothing <$ Combine.regex ".*"
        ]


parseDocTest : String -> Maybe E
parseDocTest input =
    case Combine.parse docTest input of
        Ok ( _, stream, comments ) ->
            comments

        Err ( _, stream, errors ) ->
            Nothing


parse : String -> TestSuite
parse str =
    { imports = parseImports str
    , tests =
        parseComments str
            |> List.concatMap (filterNotDocTest << List.filterMap parseDocTest << String.lines)
            |> List.Extra.groupWhile (\x y -> not <| isAssertion y)
            |> List.filterMap toTest
    }


filterNotDocTest : List E -> List E
filterNotDocTest xs =
    if List.isEmpty <| List.filter isAssertion xs then
        []
    else
        xs


toTest : List E -> Maybe Test
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


isExpectiation : E -> Bool
isExpectiation e =
    case e of
        Expectation str ->
            True

        _ ->
            False


toStr : E -> String
toStr e =
    case e of
        Assertion str ->
            str

        Continuation str ->
            str

        Expectation str ->
            str


isAssertion : E -> Bool
isAssertion e =
    case e of
        Assertion str ->
            True

        _ ->
            False
