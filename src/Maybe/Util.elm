module Maybe.Util exposing (fromList, oneOf, values)


oneOf : List (a -> Maybe b) -> a -> Maybe b
oneOf fs str =
    case fs of
        [] ->
            Nothing

        f :: rest ->
            case f str of
                Just result ->
                    Just result

                Nothing ->
                    oneOf rest str


fromList : List a -> Maybe (List a)
fromList xs =
    case xs of
        [] ->
            Nothing

        _ ->
            Just xs



-- from elm-community/maybe.extra


{-| Convert a list of `Maybe a` to a list of `a` only for the values different
from `Nothing`.
values [ Just 1, Nothing, Just 2 ] == [1, 2]
-}
values : List (Maybe a) -> List a
values =
    List.foldr foldrValues []


foldrValues : Maybe a -> List a -> List a
foldrValues item list =
    case item of
        Nothing ->
            list

        Just v ->
            v :: list
