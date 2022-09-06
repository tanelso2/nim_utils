discard """
"""

import
  nim_utils/shell_utils,
  strformat,
  strutils

const branch = "main"
const folderUrl = fmt"https://raw.githubusercontent.com/tanelso2/nim_utils/{branch}/tests/util/"
const trueUrl = folderUrl & "true.sh"
const falseUrl = folderUrl & "false.sh"

runScriptFromUrl(trueUrl)

try:
  runScriptFromUrl(falseUrl)
  assert false, "Shouldn't reach here"
except:
  assert true, "Alright"
