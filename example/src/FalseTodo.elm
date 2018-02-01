module FalseTodo exposing (..)

{-| -}


{-|

    odds : Int -> Bool
    odds x =
        x % 2 == 1

    [1,2,3,4,5]
        |> reject odds
    --> [2,4]

-}
reject : (a -> Bool) -> List a -> List a
reject pred items =
    List.filter (not << pred) items
