module VerifyExamples.ModuleName exposing (ModuleName, extendName, fromString, toString)


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



-- FROM string-extra


{-| Change the case of the first letter of a string to either uppercase or
lowercase, depending of the value of `wantedCase`. This is an internal
function for use in `toSentenceCase` and `decapitalize`.
-}
changeCase : (Char -> Char) -> String -> String
changeCase mutator word =
    String.uncons word
        |> Maybe.map (\( head, tail ) -> String.cons (mutator head) tail)
        |> Maybe.withDefault ""


{-| Capitalize the first letter of a string.
toSentenceCase "this is a phrase" == "This is a phrase"
toSentenceCase "hello, world" == "Hello, world"
-}
toSentenceCase : String -> String
toSentenceCase word =
    changeCase Char.toUpper word
