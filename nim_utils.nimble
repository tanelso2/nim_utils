# Package

version       = "0.3.0"
author        = "Thomas Nelson"
description   = "A collection of functions I've written in other projects and want to reuse."
license       = "Unlicense"
srcDir        = "src"


# Dependencies
requires "nim >= 1.6.6"
requires "yaml"

task test, "Runs the test suite":
  exec "nimble install -y && testament p 'tests/*.nim'"
