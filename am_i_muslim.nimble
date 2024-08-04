# Package

version       = "0.0.1"
author        = "hamidb80"
description   = """
  Islam short interactive stories
"""
license       = "MIT"
srcDir        = "src"
bin           = @["am_i_muslim"]


# Dependencies
requires "nim >= 2.0.0"

requires "macroplus"


task gen, "":
  exec "nim -d:nimExperimentalAsyncjsThen js -o:./libs/script.js src/frontend/main"
