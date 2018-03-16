module VerifyExamples.Markdown exposing (parseComments, testModuleName)

import Regex exposing (HowMany(..), Regex)
import Regex.Util exposing (newline)
import String.Util exposing (capitalizeFirst)
import VerifyExamples.Comment as Comment exposing (Comment(..))
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)


parseComments : String -> List Comment
parseComments =
    Regex.find All commentRegex
        >> List.filterMap (toComment << .submatches)


toComment : List (Maybe String) -> Maybe Comment
toComment matches =
    case matches of
        (Just comment) :: [] ->
            Just (ModuleDoc comment)

        _ ->
            Nothing


commentRegex : Regex
commentRegex =
    Regex.regex <|
        String.concat
            [ "```elm"
            , newline
            , "([^]*?)"
            , newline
            , "```"
            ]


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
