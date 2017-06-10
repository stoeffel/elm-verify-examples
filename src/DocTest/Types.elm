module DocTest.Types exposing (..)


type alias TestSuite =
    { imports : List String
    , tests : List Test
    , functionName : Maybe String
    , functions : List String
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
    | LocalFunction String
    | NewLine
