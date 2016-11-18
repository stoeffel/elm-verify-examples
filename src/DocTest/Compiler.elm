module DocTest.Compiler exposing (compile)

import DocTest.Types exposing (..)
import String
import Regex exposing (HowMany(..), regex)


compile : String -> TestSuite -> String
compile moduleName suite =
    String.join "\n" <|
        [ "module Doc." ++ moduleName ++ " exposing (spec)"
        , ""
        , "import Test"
        , "import Expect"
        , "import " ++ moduleName ++ " exposing(..)"
        ]
            ++ suite.imports
            ++ [ ""
               , "spec : Test.Test"
               , "spec ="
               , "    Test.describe \"" ++ moduleName ++ "\""
               ]
            ++ [ suite.tests
                    |> List.map toTest
                    |> String.join "\n    ,\n"
                    |> (\tests -> "        [\n" ++ tests ++ "\n        ]")
               ]


toTest : Test -> String
toTest test =
    String.join "\n"
        [ "        Test.test \">>> " ++ escape test.assertion ++ "\" <|"
        , "            \\() ->"
        , "                (" ++ test.assertion ++ ")"
        , "                   |> Expect.equal (" ++ test.expectation ++ ")"
        ]


escape : String -> String
escape =
    Regex.replace All (regex "\\\"") (\_ -> "\\\"")
        >> Regex.replace All (regex "\\s\\s+") (\_ -> " ")
