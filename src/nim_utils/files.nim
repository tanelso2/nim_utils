import
  os,
  strformat,
  sugar

type
  FileType* = enum
    ftFile, ftDir, ftSymlink, ftDoesNotExist

proc fileType*(s: string): FileType =
  if s.symlinkExists:
    ftSymlink
  elif s.fileExists:
    ftFile
  elif s.dirExists:
    ftDir
  else:
    ftDoesNotExist

proc dirname*(path: string): string =
  let (dir, _, _) = path.splitFile()
  return dir

proc backupPath(source: string): string = fmt"{source}.bak"

proc makeBackup*(source: string) =
  case source.fileType:
    of ftFile, ftSymlink:
      copyFile(source, source.backupPath)
    of ftDir:
      copyDir(source, source.backupPath)
    else:
      raise newException(IOError, fmt"Cannot make backup of {source}")

proc filename*(path: string): string = path.extractFilename

proc removePath*(path: string) =
  case path.fileType:
    of ftSymlink, ftFile:
      path.removeFile
    of ftDir:
      path.removeDir
    of ftDoesNotExist:
      # No need to do anything
      discard

proc collectFilesInDir*(d: string): seq[string] =
  return collect(newSeq):
    for (_, path) in walkDir(d):
      path
