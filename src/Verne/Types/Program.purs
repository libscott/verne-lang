module Verne.Types.Program
  ( module SC
  , Code(..)
  , Error(..)
  , Pos(..)
  , Program(..)
  , ProgramState(..)
  , Type(..)
  ) where

import Control.Monad.State
import Control.Monad.State.Class (get, modify) as SC
import Data.Generic
import Data.Either
import Data.Maybe
import Data.StrMap

import Prelude

import Text.Parsing.StringParser hiding (Pos(..))

import Verne.Types.Component
import Verne.Data.Namespace

-- | Core language types
--
type Type = String

type Error = String


-- | Byte offset specifier
--
type Pos = {a::Int,b::Int}


-- | Code Tree
--
data Code = List { pos::Pos, head::Code, args::Array Code }
          | Atom { pos::Pos, component::Component }


-- | Program monad
--
type Program = State ProgramState

newtype ProgramState = PS { parsers :: Namespace
                          , globals :: Namespace
                          , modules :: Namespace
                          }
