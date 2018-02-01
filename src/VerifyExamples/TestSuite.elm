module VerifyExamples.TestSuite exposing (TestSuite, fromAst, testedFunctions)

import List.Extra exposing (unique)
import VerifyExamples.Ast.Grouped as GroupedAst exposing (GroupedAst)
import VerifyExamples.Function as Function exposing (Function)
import VerifyExamples.Test as Test exposing (Test)


type alias TestSuite =
    { imports : List String
    , types : List String
    , tests : List Test
    , helperFunctions : List Function
    }


fromAst : Maybe String -> GroupedAst -> TestSuite
fromAst fnName { imports, types, functions, examples } =
    { imports = List.map GroupedAst.importToString imports
    , types = List.map GroupedAst.typeToString types
    , tests = Test.fromExamples fnName examples
    , helperFunctions = Function.toFunctions examples functions
    }


testedFunctions : TestSuite -> List String
testedFunctions =
    .tests
        >> List.filterMap Test.functionName
        >> unique
