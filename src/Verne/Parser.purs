module Verne.Parser
  ( ParseFail(..)
  , parse
  ) where

import Control.Alt
import Control.Apply
import Control.Monad.Except.Trans

import Data.Foreign
import Data.List (List(..), fromList)
import Data.Either
import Data.String (fromCharArray)

import Prelude

import Verne.Data.Code (Syntax(..))
import Verne.Data.Namespace
import Verne.Parsing
import Verne.Types

type ParseFail = {pos::Int, error::ParseError}

getPos :: Parser Int
getPos = Parser (\(s@{ pos = pos }) _ sc -> sc pos s)

parse :: String -> Program (Either ParseFail Syntax)
parse input = do
  st <- (\(Ps s) -> s) <$> get
  pure $ unParser parseSyntax {str: input, pos: 0} onErr onSuccess
  where
  onSuccess ast _ = Right ast
  onErr pos error = Left {pos,error}

parseSyntax :: Parser Syntax
parseSyntax = 
  let thePos = Posi <$> getPos <*> pure 1000000
   in thePos <*> (Syntax <$> parseArg <*> parseArgs)

parseParens :: Parser Syntax
parseParens = fix $ \_ -> do
  a <- getPos <* char '(' <* skipSpaces
  head <- parseArg <* skipSpaces
  args <- parseArgs <* skipSpaces
  b <- (eof *> pure 1000000) <|> (char ')' *> getPos)
  pure $ Posi a b $ Syntax head args

parseArgs :: Parser (Array Syntax)
parseArgs = fix $ \_ -> fromList <$> many (parseArg <* skipSpaces)

parseArg :: Parser Syntax
parseArg = fix $ \_ -> parseParens <|> parseName <|> parseString

parseName :: Parser Syntax
parseName = do
  a <- getPos
  chars <- Cons <$> lowerCaseChar <*> many myAlphaNum
  b <- getPos
  pure $ Posi a b $ Name $ fromCharArray $ fromList chars
  where
  myAlphaNum = satisfy $ \c -> c >= 'a' && c <= 'z'
                            || c >= 'A' && c <= 'Z'
                            || c >= '0' && c <= '9'

parseString :: Parser Syntax
parseString = do
  a <- getPos
  char '"'
  str <- many $ satisfy (/='"')
  b <- (eof *> pure 1000000) <|> (char '"' *> getPos)
  pure $ Posi a b $ Str $ fromCharArray $ fromList $ str