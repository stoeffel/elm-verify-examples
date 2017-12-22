module VerifyExamples.Function exposing (Function, onlyUsed, toFunction)

import VerifyExamples.GroupedAst as GroupedAst
import VerifyExamples.Test exposing (Test)


type alias Function =
    { name : String
    , function : String
    , isUsed : Bool
    }


toFunction : List Test -> GroupedAst.FunctionInfo -> Function
toFunction tests { name, function } =
    { name = name
    , function = function
    , isUsed = List.any (usedInTest name) tests
    }


usedInTest : String -> Test -> Bool
usedInTest name { assertion, expectation } =
    String.contains name assertion
        || String.contains name expectation


onlyUsed : List Function -> List Function
onlyUsed fns =
    let
        ( used, probablyNotUsed ) =
            List.partition .isUsed fns

        isUsedAfterAll f =
            List.any (String.contains f.name << .function) used

        ( fnsUsedAfterAll, notUsed ) =
            List.partition isUsedAfterAll probablyNotUsed
    in
    case fnsUsedAfterAll of
        [] ->
            fns

        xs ->
            xs
                |> List.map (\x -> { x | isUsed = True })
                |> List.append (used ++ notUsed)
                |> onlyUsed
