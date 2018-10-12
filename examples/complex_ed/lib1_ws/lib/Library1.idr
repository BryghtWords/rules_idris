module lib.Library1

import lib.Library2
import lib.Library5

export
salute1 : String
salute1 = "Hello, I'm library 1, and there is someone who wants to say something\n" ++
          salute2 ++ "\n" ++
          "  AND! I can also ask Library5!!!:\n" ++
          salute5

