module VerifyExamples.ModuleName exposing (ModuleName, extendName, fromString, toString)

import String.Extra exposing (toSentenceCase)


type ModuleName
    = ModuleName String


fromString : String -> ModuleName
fromString =
    ModuleName


toString : ModuleName -> String
toString (ModuleName name) =
    name


extendName : ModuleName -> String -> ModuleName
extendName (ModuleName name) extension =
    ModuleName (name ++ "." ++ toSentenceCase extension)
