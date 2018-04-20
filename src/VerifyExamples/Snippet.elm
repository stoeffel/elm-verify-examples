module VerifyExamples.Snippet exposing (Snippet(..))


type Snippet
    = FunctionDoc { functionName : String, snippet : String }
    | ModuleDoc String
    | ExternalDoc String


function : Snippet -> Maybe String
function comment =
    case comment of
        FunctionDoc { functionName } ->
            Just functionName

        ModuleDoc _ ->
            Nothing

        ExternalDoc _ ->
            Nothing
