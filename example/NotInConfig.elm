module NotInConfig exposing (..)

{-| run `elm-verify-examples ./NotInConfig.elm && elm-test` in this folder
-}


{-|

    hello --> "wolrd"

    hello --> "world"

-}
hello : String
hello =
    "world"


{-|

    list
    --> [ 0
    --> , 0
    --> , 0
    --> , 0
    --> , 1
    --> , 0
    --> ]

-}
list =
    [ 0, 0, 0, 0, 0, 0 ]
