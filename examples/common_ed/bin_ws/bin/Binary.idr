module Main

import lib.Library1
import lib.Library3

main : IO ()
main = putStrLn (salute1 ++ "\n\n" ++ salute3)

