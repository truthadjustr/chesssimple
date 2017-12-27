module Main where

import qualified Chesssimple.Game   as Game
import qualified Chesssimple.Player as Player
import qualified Chesssimple.Screen as Screen
import Chesssimple.Board (Position)
import Chesssimple.Color

import Data.Char (digitToInt)
import Data.List (intercalate)
import Data.List.Split (splitOn)

main :: IO ()
main =
  let player1 = Player.new "Lautaro"
      player2 = Player.new "Sabrina"
      game    = Game.new player1 player2
   in do
     Screen.reset
     Screen.printWithColor "Welcome to Simple Chess Game" "red"
     performGameTurn game

performGameTurn :: Game.Game -> IO ()
performGameTurn game
  | Game.isCheckMate game = do
      Screen.printWithColor ("Game finished! " ++ colorTurn game ++ " loses!") "red"
  | otherwise            = do
      printGameLayout game
      userInput <- getLine
      case parseCommand userInput of
        ("exit" ,         _) -> return ()
        ("which",     pos:_) -> do
          Screen.printWithColor ("Available movements are: " ++ (showAvailableMovements game (parsePosition pos))) "white"
          Screen.pause
          performGameTurn game
        ("move" , src:dst:_) -> do
          performMove game (parsePosition src) (parsePosition dst)
        _ -> do
          putStrLn $ "Bad command. Try again."
          performGameTurn game

printGameLayout :: Game.Game -> IO ()
printGameLayout game = do
  Screen.setCursor 2 0
  Screen.clearUntilEnd
  putStrLn $ Game.show game
  Screen.printWithColor (colorTurn game ++ " moves." ++ showCheckStatus game) "white"
  putStrLn "Commands are: exit, which, move"

parseCommand :: String -> (String, [String])
parseCommand userInput = let command:args = splitOn " " userInput
                          in (command, args)

parsePosition :: String -> Maybe Position
parsePosition pos = let a:b:_ = map digitToInt (take 2 pos)
                     in Just (a,b)

performMove :: Game.Game -> Maybe Position -> Maybe Position -> IO ()
performMove game Nothing dst = do
  putStrLn $ "Bad source position"
  performGameTurn game
performMove game src Nothing = do
  putStrLn $ "Bad destiny position"
  performGameTurn game
performMove game (Just src) (Just dst) =
  case (Game.tryMovement game src dst) of
    Just nextGame -> performGameTurn nextGame
    Nothing -> do
      putStrLn "Illegal movement. Try again."
      performGameTurn game

showAvailableMovements :: Game.Game -> Maybe Position -> String
showAvailableMovements game Nothing         = "No movements"
showAvailableMovements game (Just position) = let movs = Game.availableMovements game position
                                               in if null movs then "No movements"
                                                               else intercalate ", " $ map show movs

colorTurn :: Game.Game -> String
colorTurn game = case Game.turn game of
                   White -> "White"
                   Black -> "Black"

showCheckStatus :: Game.Game -> String
showCheckStatus game = if Game.isCheck game then " (and is in CHECK) "
                                            else ""
