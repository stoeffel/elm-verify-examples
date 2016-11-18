module DocTest.Types exposing (..)


type alias TestSuite =
    { imports : List String
    , tests : List Test
    }


type alias Test =
    { assertion : String
    , expectation : String
    }
