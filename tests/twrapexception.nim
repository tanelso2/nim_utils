discard """
"""

import
  nim_utils/option_utils,
  std/options,
  std/sugar

proc throws(): int =
  raise newException(IOError, "thrown from throws()")

proc returns(): int =
  1

let o1 = wrapException throws
let o2 = wrapException returns

assert o1.isNone
assert o2.isSome
assert o2.get() == 1
