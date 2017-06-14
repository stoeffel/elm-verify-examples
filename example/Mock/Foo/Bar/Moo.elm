module Mock.Foo.Bar.Moo exposing (..)

{-|


## Foo bar

@docs foo, bar, moo

-}


{-| does stuff

    foo "a" "b" "c"
    --> "bca"

    foo "a" "b" "!" --> "b!a"

-}
foo : String -> String -> String -> String
foo a b c =
    b ++ c ++ a


{-| does stuff

    bar "a" "b" "c"
    --> [ "b", "c", "a" ]

-}
bar : String -> String -> String -> List String
bar a b c =
    [ b
    , c
    , a
    ]


{-| anon function

    moo (\x y -> x + y) 3 --> 6

-}
moo : (a -> a -> a) -> a -> a
moo fn x =
    fn x x
