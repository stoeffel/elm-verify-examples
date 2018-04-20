module VerifyExamples.Markdown exposing (Parsed, parse, testModuleName)

import Regex exposing (HowMany(..), Regex)
import String.Util exposing (capitalizeFirst)
import VerifyExamples.Markdown.Snippet as Snippet exposing (Snippet(..))
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Parser as Parser
import VerifyExamples.TestSuite exposing (TestSuite)


type alias Parsed =
    { testSuites : List TestSuite }


parse : String -> Parsed
parse fileText =
    fileText
        |> Snippet.parse
        |> List.map toTestSuite
        |> Parsed


toTestSuite : Snippet -> TestSuite
toTestSuite (Snippet snippet) =
    Parser.parse { snippet = snippet, functionName = Nothing }


testModuleName : Int -> String -> ModuleName
testModuleName index filePath =
    let
        filePathComponents =
            filePath
                |> Regex.replace Regex.All (Regex.regex "\\.md$") (always "")
                |> String.split "/"

        addIndex components =
            List.append components [ "Test" ++ toString index ]
    in
    filePathComponents
        |> List.map capitalizeFirst
        |> addIndex
        |> (::) "MARKDOWN"
        |> String.join "."
        |> ModuleName.fromString
