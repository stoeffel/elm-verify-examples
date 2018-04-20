module VerifyExamples.Elm exposing (parseSnippets)

import VerifyExamples.Elm.Snippet as Snippet exposing (Snippet)


parseSnippets : String -> List Snippet
parseSnippets =
    Snippet.parse
