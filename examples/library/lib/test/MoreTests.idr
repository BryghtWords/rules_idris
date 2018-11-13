module lib.test.MoreTests

export
test : IO Bool
test = do putStrLn "Yeah"
          pure True
