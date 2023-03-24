# Package

version       = "0.4.0"
author        = "Thomas Nelson"
description   = "A collection of functions I've written in other projects and want to reuse."
license       = "Unlicense"
srcDir        = "src"


# Dependencies
requires "nim >= 1.6.6"

import
  strformat

task test, "Runs the test suite":
  exec "nimble install -y && testament p 'tests/*.nim'"

task genDocs, "Generate the docs":
  let gitHash = gorge "git rev-parse --short HEAD"
  let url = "https://github.com/tanelso2/nim_utils"
  exec fmt"nim doc --project --git.url:{url} --git.commit:{gitHash} --git.devel:main --outdir:docs src/nim_utils/"
  exec "cp docs/theindex.html docs/index.html"
