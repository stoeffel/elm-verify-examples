module VerifyExamples.Parser
    exposing
        ( Parsed
        , parse
        , parseMarkdown
        )

import VerifyExamples.Ast.Grouped as GroupedAst exposing (GroupedAst)
import VerifyExamples.Ast.Intermediate as IntermediateAst exposing (IntermediateAst)
import VerifyExamples.Elm.Snippet as ElmSnippet
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.Markdown.Snippet as MarkdownSnippet
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)


type alias Parsed =
    { exposedApi : ExposedApi
    , testSuites : List TestSuite
    }


parse : String -> Parsed
parse value =
    -- TODO: rename to parseElm
    { exposedApi =
        ExposedApi.parse value
    , testSuites =
        value
            |> ElmSnippet.parse
            |> List.map elmSnippetToTestSuite
    }


parseMarkdown : String -> Parsed
parseMarkdown value =
    { exposedApi =
        ExposedApi.parse value
    , testSuites =
        value
            |> MarkdownSnippet.parse
            |> List.map markdownSnippetToTestSuite
    }


elmSnippetToTestSuite : ElmSnippet.Snippet -> TestSuite
elmSnippetToTestSuite snippet =
    case snippet of
        ElmSnippet.FunctionDoc { functionName, snippet } ->
            toTestSuite snippet (Just functionName)

        ElmSnippet.ModuleDoc snippet ->
            toTestSuite snippet Nothing


markdownSnippetToTestSuite : MarkdownSnippet.Snippet -> TestSuite
markdownSnippetToTestSuite snippet =
    case snippet of
        MarkdownSnippet.Snippet snippet ->
            toTestSuite snippet Nothing


toTestSuite : String -> Maybe String -> TestSuite
toTestSuite snippet functionName =
    snippet
        |> IntermediateAst.fromString
        |> IntermediateAst.toAst
        |> GroupedAst.fromAst
        |> TestSuite.fromAst functionName
