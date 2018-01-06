module VerifyExamples.Warning exposing (Warning, toString, warnings)

import String.Util exposing (unlines)
import VerifyExamples.ExposedApi as ExposedApi exposing (ExposedApi)
import VerifyExamples.ModuleName as ModuleName exposing (ModuleName)
import VerifyExamples.Parser as Parser exposing (Parsed)
import VerifyExamples.TestSuite as TestSuite exposing (TestSuite)
import VerifyExamples.Warning.Ignored as Ignored exposing (Ignored)
import VerifyExamples.Warning.Type exposing (Type(..))


type Warning
    = Warning { type_ : Type, definitions : List String }


warnings : ModuleName -> List Ignored -> Parsed -> List Warning
warnings moduleName ignores { exposedApi, testSuites } =
    case
        noExamples exposedApi testSuites <|
            Ignored.only NoExampleForExposedDefinition ignores
    of
        [] ->
            []

        definitions ->
            [ Warning { type_ = NoExampleForExposedDefinition, definitions = definitions } ]


noExamples : ExposedApi -> List TestSuite -> List String -> List String
noExamples api suite ignores =
    ExposedApi.definitions <|
        ExposedApi.filter
            (\definition ->
                not (List.member definition (List.concatMap TestSuite.testedFunctions suite))
                    && not (List.member definition ignores)
            )
            api


toString : Warning -> String
toString (Warning { type_, definitions }) =
    case type_ of
        NoExampleForExposedDefinition ->
            "The following exposed definitions don't have examples:\n"
                :: List.map ((++) "    - ") definitions
                |> unlines
