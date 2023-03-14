# https://github.com/status-im/asynctest

Setup and teardown functions for suites of async tests

Could be useful for tcm testing.

# https://github.com/status-im/nim-unittest2

Parallel test execution and test suite macros and stuff

# https://github.com/PMunch/macroutils

* Utils for making macro writing cleaner

* Tree traversal helpers

* Tree verifiers

* Tree builders

* Tree extractors

Could be very useful. Test with yanyl

# https://github.com/technicallyagd/unpack

```nim
import unpack
let someSeq = @[1, 1, 2, 3, 5]
[a2, b2, c2] <- someSeq
[var d2, e2] <- someSeq
[d2, e2] <-- someSeq
# yes, <-- for assignment; <- for definitions.

let tim = Person(name: "Tim", job: "Fluffer")
{name, job} <- tim
```

# https://github.com/juancarlospaco/cliche

cli options parser. Generates a small amount of code

# https://github.com/genotrance/shared

Shared types across local thread gc. Last updated in 2019 so I doubt it is relavent to modern Nim, which uses a different gc method.

# https://github.com/nigredo-tori/classy

```nim
import classy, future

typeclass Functor, F[_]:
  # proc map[A, B](fa: F[A], g: A -> B): F[B]
  proc `$>`[A, B](fa: F[A], b: B): F[B] =
    fa.map((a: A) => g)

instance Functor, seq[_]
assert: (@[1, 2, 3] $> "a") == @["a", "a", "a"]
```

Definitely look into using this and the code it generates

# https://github.com/nim-works/cps

Claims to be faster than async/await, but is beta

Should probably look into this for tcm. Would be a big rewrite for little gain though.

# https://github.com/Vindaar/shell

```nim
shell:
  touch foo
  mv foo bar
  rm bar
```

# https://github.com/paranim/pararules

Based on a clojure libary: https://www.clara-rules.org/docs/truthmaint/

# https://github.com/planetis-m/sync

* Barrier
* Once
* RwLock
* Semaphore
* Spinlock

# https://github.com/status-im/nim-chronos

A fork of asyncdispatch looking to clean up the API
https://github.com/status-im/nim-chronos/wiki/AsyncDispatch-comparison

Definitely look into

# Contract-based programming
## DrNim
- seems incomplete
## NimContracts

More opinionated/fully featured than Contra

```nim
import contracts
from math import sqrt, floor

proc isqrt[T: SomeInteger](x: T): T {.contractual.} =
  require:
    x >= 0
  ensure:
    result * result <= x
    (result+1) * (result+1) > x
  body:
    (T)(x.toBiggestFloat().sqrt().floor().toBiggestInt())


echo isqrt(18)  # prints 4

echo isqrt(-8)  # runtime error:
                #   broke 'x >= 0' promised at FILE.nim(LINE,COLUMN)
                #   [PreConditionError]
```

## Contra

More lightweight than Contracts, can be used to do similar things.

Both have ABOUT sections that reference the other one.

