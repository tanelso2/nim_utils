discard """
"""

import
  std/tempfiles,
  os,
  strformat,
  nim_utils/files,
  nim_utils/shell_utils

let testDir = createTempDir("", "")
let testFile = fmt"{testDir}/file"

writeFile(testFile, "hello")
assert testFile.fileType == ftFile

assert testDir.fileType == ftDir

let testLink = fmt"{testDir}/link"

createSymlink(testFile, testLink)

assert testLink.fileType == ftSymlink

let testNoExist = fmt"/does/not/exist"

assert testNoExist.fileType == ftDoesNotExist
