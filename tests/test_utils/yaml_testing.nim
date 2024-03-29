import
    nim_utils/simple_yaml {.all.}

import
    tables,
    unittest

const divider* = "\n~~~~~~~~~~~~\n"
template echod*(s) =
  echo s
  echo divider

proc roundTrip*(n: YNode): YNode =
    n.toString().loadNode()

proc checkRoundTrip*(n: YNode) =
    check n == roundTrip(n)

proc checkRoundTrip*[T](x: T) =
    let n = toYaml(x)
    checkRoundTrip n

proc checkRoundTrip*(s: string) =
    let n = s.loadNode()
    checkRoundTrip n