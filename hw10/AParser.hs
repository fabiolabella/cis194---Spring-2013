{- CIS 194 HW 10
   due Monday, 1 April
-}

module AParser where

import           Control.Applicative

import           Data.Char

-- A parser for a value of type a is a function which takes a String
-- represnting the input to be parsed, and succeeds or fails; if it
-- succeeds, it returns the parsed value along with the remainder of
-- the input.
newtype Parser a = Parser { runParser :: String -> Maybe (a, String) }

-- For example, 'satisfy' takes a predicate on Char, and constructs a
-- parser which succeeds only if it sees a Char that satisfies the
-- predicate (which it then returns).  If it encounters a Char that
-- does not satisfy the predicate (or an empty input), it fails.
satisfy :: (Char -> Bool) -> Parser Char
satisfy p = Parser f
  where
    f [] = Nothing    -- fail on the empty input
    f (x:xs)          -- check if x satisfies the predicate
                        -- if so, return x along with the remainder
                        -- of the input (that is, xs)
        | p x       = Just (x, xs)
        | otherwise = Nothing  -- otherwise, fail

-- Using satisfy, we can define the parser 'char c' which expects to
-- see exactly the character c, and fails otherwise.
char :: Char -> Parser Char
char c = satisfy (== c)

{- For example:

*Parser> runParser (satisfy isUpper) "ABC"
Just ('A',"BC")
*Parser> runParser (satisfy isUpper) "abc"
Nothing
*Parser> runParser (char 'x') "xyz"
Just ('x',"yz")

-}

-- For convenience, we've also provided a parser for positive
-- integers.
posInt :: Parser Integer
posInt = Parser f
  where
    f xs
      | null ns   = Nothing
      | otherwise = Just (read ns, rest)
      where (ns, rest) = span isDigit xs

------------------------------------------------------------
-- Your code goes below here
------------------------------------------------------------

-- Exercise 1

first :: (a -> b) -> (a,c) -> (b,c)  -- Identical to Control.Arrow.first
first f (a,c) = (f a,c)

instance Functor Parser where
  fmap f p =  Parser $  \s -> fmap (first f) . runParser p $ s 

-- Exercise 2

instance Applicative Parser where
  pure v = Parser . const . Just $ (v,"")
  p1 <*> p2 = Parser $ \s-> do
    (fun,rest) <- runParser p1 s
    (value,end) <- runParser p2 rest
    return  (fun value,end)

-- Exercise 3
    
abParser :: Parser (Char, Char)
abParser = (,) <$> char 'a' <*> char 'b' 

abParser_ :: Parser ()
abParser_ = (const . const) () <$> char 'a' <*> char 'b'

intPair :: Parser [Integer]
intPair = (\n1 _ n2 -> [n1,n2]) <$> posInt <*> satisfy isSpace <*> posInt

-- Exercise 4

instance Alternative Parser where
  empty = Parser $ const empty
  p1 <|> p2 = Parser $ \s -> runParser p1 s <|> runParser p2 s
                             
-- Exercise 5
  
intOrUppercase :: Parser ()
intOrUppercase = const () <$> posInt <|> const () <$> (satisfy isUpper)

