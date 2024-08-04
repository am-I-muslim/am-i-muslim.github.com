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


task dev, "dev build":
  exec "nim js -o:./dist/libs/script.js src/frontend/main"

# randomize() proc in random module with -d:release does not work
# task rel, "release build":
#   exec "nim js -d:danger -o:./dist/libs/script.js src/frontend/main"
