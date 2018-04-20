module VerifyExamples.Markdown exposing (Parsed, compile, parse)

import Regex exposing (HowMany(..), Regex)
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


compile : String -> TestSuite -> List ( ModuleName, String )
compile filePath suite =
    Compiler.compileTestSuite (nomenclature filePath) suite


toTestSuite : Snippet -> TestSuite
toTestSuite (Snippet snippet) =
    Parser.parse { snippet = snippet, functionName = Nothing }


nomenclature : String -> Int -> Test -> ModuleName
nomenclature filePath index _ =
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
