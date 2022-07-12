discard """
"""

import
  strutils,
  nim_utils/shell_utils

let h = execOutput("echo Hello")

assert h == "Hello\n"

try:
  let h2 = execOutput("exit 3")
  assert false, "Shouldn't reach here"
except:
  assert true
