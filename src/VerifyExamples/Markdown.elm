module VerifyExamples.Markdown exposing (Parsed, compile, parse)

import Regex exposing (Regex)
import String.Util exposing (capitalizeFirst)
import VerifyExamples.Compiler as Compiler
import VerifyExamples.Markdown.Snippet as Snippet exposing (Snippet(..))
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Parser as Parser
import VerifyExamples.Test exposing (Test)
import VerifyExamples.TestSuite exposing (TestSuite)


type alias Parsed =
    { testSuites : List TestSuite }


parse : String -> Parsed
parse fileText =
    fileText
        |> Snippet.parse
        |> List.map toTestSuite
        |> Parsed


compile : String -> TestSuite -> List Compiler.Result
compile filePath suite =
    Compiler.compile
        { testModuleName = testModuleName filePath
        , testName = \test -> "Documentation VerifyExamples"
        }
        suite


toTestSuite : Snippet -> TestSuite
toTestSuite (Snippet snippet) =
    Parser.parse { snippet = snippet, functionName = Nothing }


testModuleName : String -> Int -> Test -> ModuleName
testModuleName filePath index _ =
    let
        filePathComponents =
            filePath
                |> Regex.replace (Regex.fromString "\\.md$" |> Maybe.withDefault Regex.never) (always "")
                |> String.split "/"

        addIndex components =
            List.append components [ "Test" ++ String.fromInt index ]
    in
    filePathComponents
        |> List.map capitalizeFirst
        |> addIndex
        |> (::) "MARKDOWN"
        |> String.join "."
        |> ModuleName.fromString
