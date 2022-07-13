discard """
"""

import
  strutils,
  std/tempfiles,
  nim_utils/shell_utils

let shouldFailCmd = "cat /does/not/exist"
let shouldSucceedCmd = "echo Hello"

block execOutputTest:
  let h = execOutput "echo Hello"

  assert h == "Hello\n"

  try:
    discard execOutput shouldFailCmd
    assert false, "Shouldn't reach here"
  except:
    assert true

block tryExecTest:
  assert tryExec shouldSucceedCmd
  assert not tryExec(shouldFailCmd)

block withShDirTest:
  let dirName = "helloTest"

  var currDir: string = execOutput "pwd"

  assert not currDir.contains(dirName)

  let tmpDir = createTempDir(dirName, "")

  withShDir tmpDir:
    currDir = execOutput "pwd" 
    assert currDir.contains(dirName), "Should have changed dirs"

