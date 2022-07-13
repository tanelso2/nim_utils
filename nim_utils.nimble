# Package

version       = "0.1.4"
author        = "Thomas Nelson"
description   = "A collection of functions I've written in other projects and want to reuse."
license       = "Unlicense"
srcDir        = "src"


# Dependencies
requires "nim >= 1.6.6"

task test, "Runs the test suite":
  exec "nimble install && testament p 'tests/*.nim'"
