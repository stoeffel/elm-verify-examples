module VerifyExamples.Markdown exposing (parseSnippets, testModuleName)

import Regex exposing (HowMany(..), Regex)
import String.Util exposing (capitalizeFirst)
import VerifyExamples.Markdown.Snippet as Snippet exposing (Snippet)
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)


parseSnippets : String -> List Snippet
parseSnippets =
    Snippet.parse


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
