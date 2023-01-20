import
  std/[
    options,
    strformat,
    strutils,
    tempfiles
  ],
  fusion/[
    matching
  ],
  ./logline

{.experimental: "caseStmtMacros".}

template captureStdout*(body: untyped): string =
  let (f, fname) = createTempFile("expect", "")
  let actualstdout = stdout
  logDebug("Writing stdout to " & fname)

  stdout = f

  try:
    body
  finally:
    stdout = actualstdout
    f.close()
  readFile(fname)

proc boxTrim*(s: string): string =
  var
    firstLine = none(int)
    lastLine = none(int)
    furthestLeft = none(int)
    furthestRight = none(int)
  let lines = s.split('\n')
  for (lineNum, line) in lines.pairs:
    for (i, c) in line.pairs:
      if c != ' ':
        block first:
          if firstLine.isNone():
            firstLine = some(lineNum)
        block last:
          lastLine = some(lineNum)
        block left:
          case furthestLeft
          of None():
            furthestLeft = some(i)
          of Some(@currLeft):
            if i < currLeft:
              furthestLeft = some(i)
        block right:
          case furthestRight
          of None():
            furthestRight = some(i)
          of Some(@currRight):
            if i > currRight:
              furthestRight = some(i)
  let (first, last, left, right) = (
      firstLine.get(),
      lastLine.get(),
      furthestLeft.get(),
      furthestRight.get())
  var resLines: seq[string] = @[]
  for (lineNum, line) in lines.pairs:
    if lineNum >= first and lineNum <= last:
      var currLine: string = ""
      for (i, c) in line.pairs:
        if i >= left and i <= right:
          currLine.add(c)
      resLines.add(currLine)
  result = resLines.join("\n")