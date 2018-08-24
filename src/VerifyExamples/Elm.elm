module VerifyExamples.Elm exposing (Parsed, compile, parse)

import VerifyExamples.Compiler as Compiler
import VerifyExamples.Elm.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.Elm.Nomenclature as Nomenclature
import VerifyExamples.Elm.Snippet as Snippet exposing (Snippet(..))
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
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


compile : ModuleName -> TestSuite -> List Compiler.Result
compile moduleName testSuite =
    Compiler.compile
        { testModuleName = Nomenclature.testModuleName moduleName
        , testName = Nomenclature.testName
        }
        (addSourceImport moduleName testSuite)


addSourceImport : ModuleName -> TestSuite -> TestSuite
addSourceImport moduleName testSuite =
    let
        sourceImport =
            "import " ++ ModuleName.toString moduleName ++ " exposing (..)"
    in
    { testSuite | imports = sourceImport :: testSuite.imports }


toTestSuite : Snippet -> TestSuite
toTestSuite snip =
    case snip of
        ModuleDoc snippet ->
            Parser.parse { snippet = snippet, functionName = Nothing }

        FunctionDoc { snippet, functionName } ->
            Parser.parse { snippet = snippet, functionName = Just functionName }
