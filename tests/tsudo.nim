discard """
"""

import
  std/tempfiles,
  os,
  strformat,
  nim_utils/sudo

block sudoReadFileTest:
  let (_, testFile) = createTempFile("","")
  writeFile testFile, """
    Hello world my name is
    What?
    I said my name is
    Who?
    My Name is
  """

  assert sudoReadFile(testFile) == readFile(testFile)


