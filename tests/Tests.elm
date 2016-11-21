module Tests exposing (..)

import Test exposing (..)
import DocTest.Parser
import Expect
import String


all : Test
all =
    describe "DocTest"
        [ describe "#parseImports"
            [ test "finds all imports" <|
                \() ->
                    DocTest.Parser.parseImports mockModule
                        |> Expect.equal imports
            ]
        , describe "#parseComments"
            [ test "finds all comments" <|
                \() ->
                    DocTest.Parser.parseComments mockModule
                        |> Expect.equal comments
            ]
        , describe "#parse"
            [ test "parses the suite" <|
                \() ->
                    DocTest.Parser.parse mockModule
                        |> Expect.equal ast
            ]
        ]


mockModule : String
mockModule =
    """
module Foo exposing (..)

import String
import Dict


{-| Sum

    >>> add 3 4
    7

    >>> add 42 42
    84
-}
add : Int -> Int -> Int
add =
    (+)

"""


imports : List String
imports =
    [ "import String"
    , "import Dict"
    ]


comments : List String
comments =
    [ "    >>> add 3 4"
    , "    7"
    , "    >>> add 42 42"
    , "    84"
    ]


ast =
    { imports = imports
    , tests =
        [ { assertion = "add 3 4"
          , expectation = "7"
          }
        , { assertion = "add 42 42"
          , expectation = "84"
          }
        ]
    }
