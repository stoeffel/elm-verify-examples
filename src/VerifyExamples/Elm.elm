module VerifyExamples.Elm exposing (Parsed, compile, parse)

import VerifyExamples.Compiler as Compiler
import VerifyExamples.Elm.Snippet as Snippet exposing (Snippet(..))
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Parser as Parser
import VerifyExamples.Test as Test exposing (Test)
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


compile : ModuleName -> TestSuite -> List ( ModuleName, String )
compile moduleName testSuite =
    Compiler.compileTestSuite
        (nomenclature moduleName)
        (addSourceImport moduleName testSuite)


addSourceImport : ModuleName -> TestSuite -> TestSuite
addSourceImport moduleName testSuite =
    let
        sourceImport =
            "import " ++ ModuleName.toString moduleName ++ " exposing (..)"
    in
    { testSuite | imports = sourceImport :: testSuite.imports }


nomenclature : ModuleName -> Int -> Test -> ModuleName
nomenclature moduleName index test =
    Test.specName index test
        |> ModuleName.extendName moduleName


toTestSuite : Snippet -> TestSuite
toTestSuite snippet =
    case snippet of
        ModuleDoc snippet ->
            Parser.parse { snippet = snippet, functionName = Nothing }

        FunctionDoc { snippet, functionName } ->
            Parser.parse { snippet = snippet, functionName = Just functionName }
