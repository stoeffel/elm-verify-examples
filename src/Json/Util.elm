module Json.Util exposing (exact)

import Json.Decode as Decode exposing (Decoder)


{-| A decoder that only succeeds when it decodes to the given value.
-}
exact : Decoder a -> a -> Decoder a
exact decoder x =
    Decode.andThen
        (\y ->
            if x == y then
                Decode.succeed x
            else
                Decode.fail ("expected " ++ toString x ++ " got " ++ toString y)
        )
        decoder
