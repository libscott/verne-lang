module Verne.Utils where

import Data.Foreign

import Prelude

foreign import infinity :: Int

foreign import dump :: forall a. a -> String

foreign import unqualifyShow :: String -> String

foreign import isSame :: forall a. a -> a -> Boolean

foreign import hashOne :: String -> String

foreign import hashMany :: Array String -> String

foreign import nullValue :: Unit -> Unit

foreign import curryForeign :: Foreign -> Foreign -> Foreign

foreign import autoCurry :: Foreign -> Foreign -> Foreign
