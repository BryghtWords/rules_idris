module lib.Library2

import lib.Library3
import lib.Library5

export
salute2 : String
salute2 = "Hello, this is Library 2, friend of Library 3 who salutes:\n" ++
          "    " ++ salute3 ++ "\n" ++
          "    and another friend who also salutes:\n" ++
          "    " ++ salute5

