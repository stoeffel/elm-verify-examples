module VerifyExamples.Elm exposing (Parsed, parse)

import VerifyExamples.Elm.Snippet as Snippet exposing (Snippet(..))
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.Parser as Parser
import VerifyExamples.TestSuite exposing (TestSuite)


type alias Parsed =
    { exposedApi : ExposedApi
    , testSuites : List TestSuite
    }


parse : String -> Parsed
parse fileText =
    { exposedApi =
        ExposedApi.parse fileText
    , testSuites =
        fileText
            |> Snippet.parse
            |> List.map toTestSuite
    }


toTestSuite : Snippet -> TestSuite
toTestSuite snippet =
    case snippet of
        ModuleDoc snippet ->
            Parser.parse { snippet = snippet, functionName = Nothing }

        FunctionDoc { snippet, functionName } ->
            Parser.parse { snippet = snippet, functionName = Just functionName }
