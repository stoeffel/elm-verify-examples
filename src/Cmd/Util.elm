module Cmd.Util exposing (perform)

import Task


perform : msg -> Cmd msg
perform x =
    Task.perform (\_ -> x) (Task.succeed ())
