module Mock exposing (..)

{-|

@docs add, sum, bar, rev, IsItCool, coolFunc

    -- These imports are only used in verify-examples
    import Dict exposing (Dict, fromList)
    import String exposing (join)

-}

import Dict exposing (Dict, fromList)


{-| returns the sum of two int.

    add 41 1
    --> 42

    add 3 3 --> 6

-}
add : Int -> Int -> Int
add =
    (+)


{-|

    inc $ inc 1 --> 3

    add : Int -> Int -> Int
    add = (+)

    inc : Int -> Int
    inc x = add 1 x

-}
($) : (a -> b) -> a -> b
($) f x =
    f x


{-| Cool or not
-}
type IsItCool
    = Cool
    | Uncool


{-| This is my cool function.

    -- This is how you use it in a view.

    view : Html msg
    view =
        case coolFunc 42 of
            Cool -> showSomeCoolStuff
            NotCool -> text "uncool, man"

    -- Cool values

    coolFunc 42    --> Cool

    coolFunc 10000 --> Cool

    -- Uncool values

    coolFunc 1 --> Uncool

-}
coolFunc : Int -> IsItCool
coolFunc x =
    case x of
        42 ->
            Cool

        10000 ->
            Cool

        _ ->
            Uncool


{-| returns the sum of a list of int

    sum aList -- no expectation, this is not a test

    sum
        [ 41
        , 1
        ]
    --> 42

-}
sum : List Int -> Int
sum =
    List.foldl (+) 0


{-|

    import Dict exposing (Dict, fromList)

    bar 1 "foo"
    --> fromList [(1, "foo")]

-}
bar : Int -> String -> Dict Int String
bar a b =
    fromList [ ( a, b ) ]


{-| reverses the list

    rev
        [ 41
        , 1
        ]
    --> [ 1
    --> , 41
    --> ]

    rev [1, 2, 3]
        |> List.map toString
        |> join ""
    --> "321"

-}
rev : List a -> List a
rev =
    List.reverse


{-| some inline comments

    -- comment
    quux 10 32 -- another
    --> 42 --result

-}
quux : Int -> Int -> Int
quux n m =
    n + m


{-| with a custom type in the example

    type Foo
        = A
        | B

    customType B 1
    --> (B, 1)

-}
customType : a -> Int -> ( a, Int )
customType n m =
    ( n, m )


{-| with a custom type alias in the example

    customTypeAlias defaultUser "?"
    --> "?Luke"

    type alias User =
        { id: Int -- ID
        , name: String
        }

    defaultUser : User
    defaultUser =
        { id = 1
        , name = "Luke"
        }

    customTypeAlias defaultUser "_"
    --> "_Luke"

-}
customTypeAlias : { a | name : String } -> String -> String
customTypeAlias { name } prefix =
    prefix ++ name
