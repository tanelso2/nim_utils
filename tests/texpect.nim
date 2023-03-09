import
  nim_utils/expect,
  nim_utils/import_utils,
  macros,
  os

importCompiler "ast"
importCompiler "idents"
importCompiler "msgs"
importCompiler "options"
importCompiler "parser"
importCompiler "pathutils"
importCompiler "renderer"
importCompiler "syntaxes"

# Notes:
# layouter defines an emitter, but that only works if nimpretty is defined
#   emitter also only works inside the parser, so wouldn't be helpful in turning PNodes into code
# How does expandMacros do it?
# Could just copy file and use PNode info to find/replace smarter


proc parseAFile(): PNode =
  var parser: Parser
  var conf = newConfigRef()
  let fileIdx = fileInfoIdx(conf, AbsoluteFile currentSourcePath)
  if setupParser(parser, fileIdx, newIdentCache(), conf):
    result = parser.parseAll()

echo parseAFile().renderTree

expectTest:
  echo "Hello" 
  expect """
    Hello
  """

  echo "Hello2"
  expect """
    Hello2
  """

  for i in 1..5:
    echo i
  expect """
    1
    2
    3
    4
    5
  """
  echo getCurrentCompilerExe().parentDir.parentDir
  expect ""

