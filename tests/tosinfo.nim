discard """
  disabled: "win"
  disabled: "osx"
"""

import
  nim_utils/distros,
  tables

let osInfo = getOsInfo()
assert osInfo.hasKey("ID")
