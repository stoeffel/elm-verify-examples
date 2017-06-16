module VerifyExamples.Types exposing (..)


type alias TestSuite =
    { imports : List String
    , tests : List Test
    }


type alias Test =
    { assertion : String
    , expectation : String
    }


type Syntax
    = Assertion String
    | Continuation String
    | Expectation String
    | Import String
    | NewLine
