module Mock.Foo.Bar.Moo exposing (..)

{-| does stuff

    > foo "a" "b" "c"
    "bca"
-}


foo : String -> String -> String -> String
foo a b c =
    b ++ c ++ a


{-| does stuff

    > bar "a" "b" "c"
    [ "b", "c", "a" ]
-}
bar : String -> String -> String -> List String
bar a b c =
    [ b
    , c
    , a
    ]
