import
  std/[
    options,
    strformat,
    tempfiles
  ]

type 
  TestOutcome* = enum
    toSuccess, toFailure
  TestResult* = object of RootObj
    fileLocation*: void
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
  fmt"expect-{ctx.currSourceFile}-{blockName}-{idx}"

proc newTmpFile(ctx: var ExpectContext) =
  let prefix = ctx.getPrefix()
  let (newFile, name) = createTempFile(prefix = prefix, suffix = "", dir = ctx.outputFileDir)
  ctx.currStdout = newFile
  stdout = newFile
  ctx.currStdoutFilename = name

proc newContext*(): ExpectContext =
  let outputFileDir = createTempDir("expect-testing", "")
  result = ExpectContext(
    idx: 0, 
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

proc recordFailure*(ctx: var ExpectContext, expected, actual: string) =
  let tr = TestResult(outcome: toFailure, expected: expected, actual: actual)
  ctx.results.add(tr)

proc recordSuccess*(ctx: var ExpectContext) =
  let tr = TestResult(outcome: toSuccess)
  ctx.results.add(tr)
  
proc reportResults*(ctx: var ExpectContext) = 
  let results = ctx.results
  for res in results:
    if res.outcome == toSuccess:
      echo "success"
    else:
      echo "failure"
      quit 1
  