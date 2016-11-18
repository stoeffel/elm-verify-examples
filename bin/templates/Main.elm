port module Doc.Main exposing (..)

import Doc.Tests
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit Doc.Tests.all


port emit : ( String, Value ) -> Cmd msg
