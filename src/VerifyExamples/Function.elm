module VerifyExamples.Function exposing (Function, fromAst, onlyUsed)

import VerifyExamples.Ast as Ast exposing (Ast)
import VerifyExamples.Test exposing (Test)


type alias Function =
    { name : String
    , value : String
    , isUsed : Bool
    }


fromAst : List Test -> Ast -> Maybe Function
fromAst tests ast =
    case ast of
        Ast.Function name value ->
            Just
                { name = name
                , value = value
                , isUsed = List.any (usedInTest name) tests
                }

        Ast.Assertion _ ->
            Nothing

        Ast.Expectation _ ->
            Nothing

        Ast.Import _ ->
            Nothing

        Ast.Type _ ->
            Nothing


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
            List.any (String.contains f.name << .value) used

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
