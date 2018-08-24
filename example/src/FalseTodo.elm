module FalseTodo exposing (reject)

{-| -}


{-|

    odds : Int -> Bool
    odds x =
        remainderBy 2 x == 1

    [1,2,3,4,5]
        |> reject odds
    --> [2,4]

-}
reject : (a -> Bool) -> List a -> List a
reject pred items =
    List.filter (not << pred) items
