module Verne.Data.Code
  ( Pos(..)
  , Code(..)
  , getPos
  ) where

import Data.Array

import Verne.Data.Component

-- | Byte offset specifier
--
type Pos = {a::Int,b::Int}

-- | Code Tree
--
data Code = List { pos::Pos, head::Code, args::Array Code }
          | Atom { pos::Pos, component::Component }

getPos :: Code -> Pos
getPos (Atom {pos}) = pos
getPos (List {pos}) = pos
