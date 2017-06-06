module DocTest.Compiler exposing (compile)

import DocTest.Types exposing (..)
import Regex exposing (HowMany(..), regex)
import String


compile : String -> TestSuite -> String
compile moduleName suite =
    String.join "\n" <|
        List.concatMap identity
            [ moduleHeader moduleName suite.imports
            , testDescribe moduleName
            , testBodies suite.tests
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


testDescribe : String -> List String
testDescribe moduleName =
    [ ""
    , "spec : Test.Test"
    , "spec ="
    , indent 1 "Test.describe \"" ++ moduleName ++ "\""
    ]


testBodies : List Test -> List String
testBodies tests =
    [ tests
        |> List.map toTest
        |> String.join ",\n"
        |> (\tests -> indent 2 "[\n" ++ tests ++ "\n        ]")
    ]


toTest : Test -> String
toTest test =
    String.join "\n"
        [ indent 2 "Test.test \">>> " ++ escape test.assertion ++ "\" <|"
        , indent 3 "\\() ->"
        , indent 4 "("
        , indent 5 test.assertion
        , indent 4 ") |> Expect.equal ("
        , indent 5 test.expectation
        , indent 4 ")"
        ]


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
