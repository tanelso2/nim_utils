import
  std/logging,
  strutils

type Level* = logging.Level

let logger = newConsoleLogger(fmtStr="[$time] ")
addHandler(logger)

proc levelName*(lvl: Level): string =
  LevelNames[lvl]

template log*(lvl: Level, msg: string) =
  let pos = instantiationInfo()
  logging.log(lvl, "$1:$2:$3: $4" % [pos.filename, $pos.line, lvl.levelName, msg])

template logDebug*(msg: string) =
  log(lvlDebug, msg)

template logInfo*(msg: string) =
  log(lvlInfo, msg)

template logError*(msg: string) =
  log(lvlError, msg)

template logWarn*(msg: string) =
  log(lvlWarn, msg)
