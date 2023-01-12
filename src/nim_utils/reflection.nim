import
  macros,
  sequtils,
  sugar

type
  NimVariant = object of RootObj
    name: string
    fields: seq[string]
  ObjFields = object of RootObj
    common: seq[string]
    variants: seq[NimVariant]
  
proc collectFields(x: NimNode): seq[string] =
  proc recurseChildren(x: NimNode): seq[string] =
    let r = collect:
      for c in x.children:
        collectFields(c)
    return concat(r)

  case x.kind
  of nnkIdent:
    return @[x.strVal]
  of nnkIdentDefs:
    return collectFields(x[0])
  of nnkEmpty:
    return @[]
  of nnkSym:
    return @[]
  of nnkOfInherit:
    let parentClassSym = x[0]
    if parentClassSym.strVal == "RootObj":
      return @[]
    else:
      # echo "GOT INHERITANCE"
      return collectFields(parentClassSym.getImpl())
  of nnkRecList:
    return recurseChildren(x)
  of nnkObjectTy:
    return recurseChildren(x)
  of nnkTypeDef:
    return recurseChildren(x)
  of nnkRefTy:
    return recurseChildren(x)
  of nnkRecCase:
    raise newException(ValueError, "No implementation for variants yet")
  else:
    raise newException(ValueError, "boo")

proc collectFieldsForType*(t: NimNode): seq[string] =
  expectKind(t, nnkTypeDef)
  collectFields(t)
