module VerifyExamples.Function exposing (Function, toFunctions, toString)

import VerifyExamples.GroupedAst as GroupedAst exposing (Example, FunctionInfo)


type Function
    = Function
        { name : String
        , function : String
        }


toFunctions : List Example -> List GroupedAst.Function -> List Function
toFunctions examples =
    List.map (GroupedAst.functionInfo >> Function)
        >> List.partition (inAnyExample examples)
        >> usedFunctions


toString : Function -> String
toString (Function { function }) =
    function


usedFunctions : ( List Function, List Function ) -> List Function
usedFunctions ( used, fns ) =
    case
        List.partition (inAnyFunction used) fns
    of
        ( [], _ ) ->
            used

        ( alsoUsed, [] ) ->
            used ++ alsoUsed

        rest ->
            used ++ usedFunctions rest


inAnyFunction : List Function -> Function -> Bool
inAnyFunction functions (Function { name }) =
    List.any (String.contains name << toString) functions


inAnyExample : List Example -> Function -> Bool
inAnyExample examples function =
    List.any (isUsedInExample function) examples


isUsedInExample : Function -> Example -> Bool
isUsedInExample (Function { name }) { assertion, expectation } =
    String.contains name assertion
        || String.contains name expectation
