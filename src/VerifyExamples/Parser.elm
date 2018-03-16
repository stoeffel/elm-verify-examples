module VerifyExamples.Parser
    exposing
        ( Parsed
        , parse
        , parseMarkdown
        )

import VerifyExamples.Ast.Grouped as GroupedAst exposing (GroupedAst)
import VerifyExamples.Ast.Intermediate as IntermediateAst exposing (IntermediateAst)
import VerifyExamples.Comment as Comment exposing (Comment)
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.Markdown as Markdown
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
            -- TODO: move Elm parsing to Elm.parseComments ?
            |> Comment.parse
            |> List.map toTestSuite
    }


parseMarkdown : String -> Parsed
parseMarkdown value =
    { exposedApi =
        ExposedApi.parse value
    , testSuites =
        value
            |> Markdown.parseComments
            |> List.map toTestSuite
    }


toTestSuite : Comment -> TestSuite
toTestSuite comment =
    case comment of
        Comment.FunctionDoc { functionName, comment } ->
            comment
                |> IntermediateAst.fromString
                |> IntermediateAst.toAst
                |> GroupedAst.fromAst
                |> TestSuite.fromAst (Just functionName)

        Comment.ModuleDoc comment ->
            comment
                |> IntermediateAst.fromString
                |> IntermediateAst.toAst
                |> GroupedAst.fromAst
                |> TestSuite.fromAst Nothing
