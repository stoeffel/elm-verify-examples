module VerifyExamples.Function exposing (Function, toFunctions, toString)

import VerifyExamples.GroupedAst as GroupedAst exposing (Example, FunctionInfo)


type Function
    = Function
        { name : String
        , function : String
        , isUsed : Bool
        }


toFunctions : List GroupedAst.Function -> List Example -> List Function
toFunctions grouped examples =
    List.map (GroupedAst.functionInfo >> toFunction examples) grouped
        |> onlyUsed
        |> List.filter isUsed


toString : Function -> String
toString (Function { function }) =
    function


toFunction : List Example -> FunctionInfo -> Function
toFunction examples { name, function } =
    Function
        { name = name
        , function = function
        , isUsed = List.any (usedInTest name) examples
        }


usedInTest : String -> Example -> Bool
usedInTest name { assertion, expectation } =
    String.contains name assertion
        || String.contains name expectation


onlyUsed : List Function -> List Function
onlyUsed fns =
    let
        ( used, probablyNotUsed ) =
            List.partition isUsed fns

        isUsedAfterAll f =
            List.any (\(Function { name, function }) -> String.contains name function) used

        ( fnsUsedAfterAll, notUsed ) =
            List.partition isUsedAfterAll probablyNotUsed
    in
    case fnsUsedAfterAll of
        [] ->
            fns

        xs ->
            xs
                |> List.map (\(Function x) -> Function { x | isUsed = True })
                |> List.append (used ++ notUsed)
                |> onlyUsed


isUsed : Function -> Bool
isUsed (Function { isUsed }) =
    isUsed
