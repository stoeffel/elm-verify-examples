module DocTest.Compiler exposing (compile)

import DocTest.Types exposing (..)
import Regex exposing (HowMany(..), regex)
import String


compile : String -> List TestSuite -> String
compile moduleName suites =
    let
        filteredSuites =
            List.filter (.tests >> List.isEmpty >> not) suites
    in
    String.join "\n" <|
        List.concat
            [ moduleHeader moduleName <| List.concatMap .imports suites
            , spec moduleName filteredSuites
            ]


moduleHeader : String -> List String -> List String
moduleHeader moduleName imports =
    [ "module Doc." ++ moduleName ++ "Spec exposing (spec)"
    , ""
    , "import Test"
    , "import Expect"
    , "import " ++ moduleName ++ " exposing(..)"
    ]
        ++ imports


spec : String -> List TestSuite -> List String
spec moduleName suites =
    let
        renderedSuites =
            List.indexedMap toDescribe suites
                |> List.concat
    in
    [ ""
    , ""
    , "spec : Test.Test"
    , "spec ="
    , indent 1 "Test.describe \"" ++ escape moduleName ++ "\" <|"
    ]
        ++ List.map (indent 2) renderedSuites
        ++ [ indent 1 "]" ]


toDescribe : Int -> TestSuite -> List String
toDescribe index suite =
    let
        renderedTests =
            List.indexedMap toTest suite.tests
                |> List.concat
    in
    (startOfListOrNot index
        ++ "Test.describe \""
        ++ (suite.functionName
                |> Maybe.map ((++) "#")
                |> Maybe.withDefault ("Comment: " ++ toString (index + 1))
                |> escape
           )
        ++ "\" <|"
    )
        :: List.map (indent 1) renderedTests
        ++ [ indent 1 "]" ]


toDescribtion : Test -> String
toDescribtion test =
    escape test.assertion ++ " --> " ++ escape test.expectation


toTest : Int -> Test -> List String
toTest index test =
    [ indent 0
        (startOfListOrNot index
            ++ "Test.test \""
            ++ toDescribtion test
            ++ "\" <|"
        )
    , indent 1 "\\() ->"
    , indent 2 "Expect.equal"
    , indent 3 ("(" ++ test.assertion)
    , indent 3 ")"
    , indent 3 ("(" ++ test.expectation)
    , indent 3 ")"
    ]


startOfListOrNot : Int -> String
startOfListOrNot index =
    if index == 0 then
        "[ "
    else
        ", "


indent : Int -> String -> String
indent count str =
    List.repeat (count * 4) " "
        ++ [ str ]
        |> String.join ""


escape : String -> String
escape =
    Regex.replace All (regex "\\\\") (\_ -> "\\\\")
        >> Regex.replace All (regex "\\\"") (\_ -> "\\\"")
        >> Regex.replace All (regex "\\s\\s+") (\_ -> " ")
