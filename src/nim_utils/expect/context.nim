import
  std/[
    options,
    os,
    strformat,
    tempfiles
  ]

type 
  InstantiationInfo* = tuple
    filename: string
    line: int
    column: int
  TestOutcome* = enum
    toSuccess, toFailure
  TestResult* = object of RootObj
    fileLocation*: InstantiationInfo
    case outcome*: TestOutcome
    of toSuccess:
      discard
    of toFailure:
      expected*: string
      actual*: string
  ExpectContext* = object of RootObj
    currSourceFile*: string
    currStdout*: File
    currStdoutFilename*: string
    actualStdout*: File
    blockName*: Option[string]
    outputFileDir*: string
    idx*: int
    results*: seq[TestResult]

proc getPrefix(ctx: var ExpectContext): string =
  let blockName = ctx.blockName.get(otherwise = "")
  let idx = $ctx.idx
  ctx.idx = ctx.idx + 1
  fmt"expect-{ctx.currSourceFile.extractFilename}-{blockName}-{idx}"

proc newTmpFile(ctx: var ExpectContext) =
  let prefix = ctx.getPrefix()
  let (newFile, name) = createTempFile(prefix = prefix, suffix = "", dir = ctx.outputFileDir)
  ctx.currStdout = newFile
  stdout = newFile
  ctx.currStdoutFilename = name

proc newContext*(source: string): ExpectContext =
  let outputFileDir = createTempDir("expect-testing", "")
  result = ExpectContext(
    idx: 0, 
    currSourceFile: source,
    # TODO: currSourceFile
    # TODO: blockName
    actualStdout: stdout, 
    outputFileDir: outputFileDir,
    results: @[])
  result.newTmpFile()

proc readOutput*(ctx: var ExpectContext): string =
  let outputFile = ctx.currStdoutFilename
  ctx.currStdout.close()
  ctx.newTmpFile()
  readFile(outputFile)

proc restoreStdout*(ctx: var ExpectContext) =
  stdout = ctx.actualStdout

proc recordFailure*(ctx: var ExpectContext, loc: InstantiationInfo, expected, actual: string) =
  let tr = TestResult(outcome: toFailure, fileLocation: loc, expected: expected, actual: actual)
  ctx.results.add(tr)

proc recordSuccess*(ctx: var ExpectContext, loc: InstantiationInfo) =
  let tr = TestResult(outcome: toSuccess, fileLocation: loc)
  ctx.results.add(tr)
  
proc reportResults*(ctx: var ExpectContext) = 
  let results = ctx.results
  var failed = false
  for res in results:
    if res.outcome == toSuccess:
      echo "* success"
    else:
      echo "x failure at " & $res.fileLocation
      echo "~~~~~~Expected~~~~~~"
      echo res.expected
      echo "~~~~~~~Actual~~~~~~~"
      echo res.actual
      echo "~~~~~~~~~~~~~~~~~~~~"
      failed = true
  if failed:
    echo "Run had failures"
    quit 1
  