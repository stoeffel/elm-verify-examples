module VerifyExamples.Warnings exposing (Warnings, toString, warnings)

import String.Util exposing (unlines)
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.IgnoredWarnings as IgnoredWarnings exposing (IgnoredWarnings)
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Parser as Parser exposing (Parsed)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)
import VerifyExamples.Warning as Warning exposing (Warning(..))


type Warnings
    = Warnings { type_ : Warning, definitions : List String }


warnings : ModuleName -> List IgnoredWarnings -> Parsed -> List Warnings
warnings moduleName ignores { exposedApi, testSuites } =
    case
        noExamples exposedApi testSuites <|
            IgnoredWarnings.only NoExampleForExposedDefinition ignores
    of
        [] ->
            []

        definitions ->
            [ Warnings { type_ = NoExampleForExposedDefinition, definitions = definitions } ]


noExamples : ExposedApi -> List TestSuite -> List String -> List String
noExamples api suite ignores =
    ExposedApi.definitions <|
        ExposedApi.filter
            (\definition ->
                not (List.member definition (List.concatMap TestSuite.testedFunctions suite))
                    && not (List.member definition ignores)
            )
            api


toString : Warnings -> String
toString (Warnings { type_, definitions }) =
    case type_ of
        NoExampleForExposedDefinition ->
            "The following exposed definitions don't have examples:\n"
                :: List.map ((++) "    - ") definitions
                |> unlines
