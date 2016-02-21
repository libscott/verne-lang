module Verne.Program.Parser
  ( module SP
  , ParseFail(..)
  , parse
  ) where

import Control.Alt
import Control.Apply
import Control.Monad.Except.Trans

import Data.Either
import Data.List (List(..), fromList)
import Data.String (fromCharArray)

import Prelude

import Text.Parsing.StringParser hiding (Pos(..))
import Text.Parsing.StringParser.Combinators
import Text.Parsing.StringParser.String
import qualified Text.Parsing.StringParser (ParseError(..)) as SP

import Verne.Types.Program
import Verne.Types.Component

import Verne.Data.Namespace

type ParseFail = {pos::Int, error::ParseError}


-- | Maxpos is a number that's always bigger than another number.
-- In this case the length of a code expression. Used to mean "infinity".
maxpos :: Int
maxpos = 1000000

getPos :: Parser Int
getPos = Parser (\(s@{ pos = pos }) _ sc -> sc pos s)

parseCode :: ProgramState -> Parser Code
parseCode st =
  List <$> ({pos:_,head:_,args:_}
         <$> thePos <*> parseArg <*> parseArgs)
  where
  thePos = (\a b -> {a,b}) <$> getPos <*> pure maxpos

  parseParens :: Parser Code
  parseParens = fix $ \_ -> do
    a <- getPos <* char '(' <* skipSpaces
    head <- parseArg <* skipSpaces
    args <- parseArgs <* skipSpaces
    b <- (eof *> pure maxpos) <|> (char ')' *> getPos)
    pure $ List {pos:{a,b},head,args}

  parseArgs :: Parser (Array Code)
  parseArgs = fix $ \_ -> fromList <$> many (parseArg <* skipSpaces)

  parseArg :: Parser Code
  parseArg = fix $ \_ -> parseParens <|> parseName <|> parseStr

  -- TODO: this should live in Verne.Data
  -- TODO: anything anonymous is fair game for tight compilation.
  -- TODO: Verne.String exports string functions and parser
  parseStr :: Parser Code
  parseStr = do
    a <- getPos
    char '"'
    str <- many $ satisfy $ (not <<< (=='"'))
    b <- (eof *> pure maxpos) <|> (char '"' *> getPos)
    let pos = {a,b}
        component = valueComponent "String" (fromCharArray $ fromList str)
    pure $ Atom {pos, component}

  parseName :: Parser Code
  parseName = do
    a <- getPos
    chars <- Cons <$> lowerCaseChar <*> many myAlphaNum
    b <- getPos
    let name = fromCharArray $ fromList chars
    pure $ Atom {pos:{a,b},component:nameComponent name}
    where
    myAlphaNum = satisfy $ \c -> c >= 'a' && c <= 'z'
                              || c >= 'A' && c <= 'Z'
                              || c >= '0' && c <= '9' 


parse :: String -> Program (Either ParseFail Code)
parse input = do
  st <- get
  pure $ unParser (parseCode st) {str: input, pos: 0} onErr onSuccess
  where
  onSuccess ast _ = Right ast
  onErr pos error = Left {pos,error}
