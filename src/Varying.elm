module Varying
    ( Varying
    , fromStream, toStream, destructure
    , map, map2, map3, map4, map5
    , (<~), (~)
    , constant
    ) where

{-| A *varying* value is a value that changes over time. For example, we can
think of the mouse position as a pair of numbers that is changing over time,
whenever the user moves the mouse.

    Mouse.position : Varying (Int,Int)

Another varying value is the `Element` or `Html` we want to show on screen.

    main : Varying Html

As the `Html` changes, the user sees different things on screen automatically.

# Mapping
@docs map, map2, map3, map4, map5

# Fancy Mapping
@docs (<~), (~)

# Conversions
@docs toStream, fromStream, destructure

# Constant
@docs constant
-}

import Native.Signal
import Signal exposing (Stream)


type alias Varying a =
    Signal.Varying a


{-| Create a varying value that never changes. This can be useful if you need
to pass a combination of varyings and normal values to a function:

    map3 view Window.dimensions Mouse.position (constant initialModel)
-}
constant : a -> Varying a
constant =
  Native.Signal.constant


{-| Convert a stream of values into a varying value that updates whenever an
event comes in on the stream.

    url : Varying String
    url =
      fromStream "waiting.gif" imageStream

    constant : a -> Varying a
    constant value =
      fromStream value Stream.never
-}
fromStream : a -> Stream a -> Varying a
fromStream =
  Native.Signal.streamToVarying


{-| Get a stream that triggers whenever the varying value is *updated*. Note
that an update may result in the same value as before, so the resulting
`Stream` can have the same value twice in a row.

    moves : Stream (Int,Int)
    moves =
      toStream Mouse.position
-}
toStream : Varying a -> Stream a
toStream =
  Native.Signal.varyingToStream


{-| Destructure a varying value, resulting in the initial value and a stream
of all the updates. These things are conceptually equivalent.

This can be useful when you need the window dimensions to render your scene,
but you also need to update your model when a resize occurs.

    (initialSize, resizes) : ((Int,Int), Stream (Int,Int))
    (initialSize, resizes) =
      destructure Window.dimensions
-}
destructure : Varying a -> (a, Stream a)
destructure varying =
  (Native.Signal.initialValue varying, toStream varying)


{-| Apply a function to a varying value.

    mouseIsUp : Varying Bool
    mouseIsUp =
        map not Mouse.isDown

    main : Varying Element
    main =
        map toElement Mouse.position
-}
map : (a -> result) -> Varying a -> Varying result
map =
  Native.Signal.map


{-| Apply a function to the current value of two varying values. The function
is reevaluated whenever *either* varying changes. In the following example, we
figure out the `aspectRatio` of the window by combining the current width and
height.

    ratio : Int -> Int -> Float
    ratio width height =
        toFloat width / toFloat height

    aspectRatio : Varying Float
    aspectRatio =
        map2 ratio Window.width Window.height
-}
map2 : (a -> b -> result) -> Varying a -> Varying b -> Varying result
map2 =
  Native.Signal.map2


map3 : (a -> b -> c -> result) -> Varying a -> Varying b -> Varying c -> Varying result
map3 =
  Native.Signal.map3


map4 : (a -> b -> c -> d -> result) -> Varying a -> Varying b -> Varying c -> Varying d -> Varying result
map4 =
  Native.Signal.map4


map5 : (a -> b -> c -> d -> e -> result) -> Varying a -> Varying b -> Varying c -> Varying d -> Varying e -> Varying result
map5 =
  Native.Signal.map5


{-| An alias for `map`. A prettier way to apply a function to the current value
of a signal.

    main : Varying Html
    main =
      view <~ model

    model : Varying Model

    view : Model -> Html
-}
(<~) : (a -> b) -> Varying a -> Varying b
(<~) =
  map


{-| Intended to be paired with the `(<~)` operator, this makes it possible for
many varying values to flow into a function. Think of it as a fancy alias for
`mapN`. For example, the following declarations are equivalent:

    main : Varying Element
    main =
      scene <~ Window.dimensions ~ Mouse.position

    main : Varying Element
    main =
      map2 scene Window.dimensions Mouse.position

You can use this pattern for as many signals as you want by using `(~)` a bunch
of times, so you can go higher than `map5` if you need to.
-}
(~) : Varying (a -> b) -> Varying a -> Varying b
(~) funcs args =
  map2 (\f v -> f v) funcs args


infixl 4 <~
infixl 4 ~


