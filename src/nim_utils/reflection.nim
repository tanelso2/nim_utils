import
  macros,
  sequtils,
  strformat,
  sugar

type
  Field* = object of RootObj
    name*: string
    t*: NimNode
  ObjType* = enum
    otObj, otVariant, otEnum, otEmpty
  NimVariant* = object of RootObj
    name*: string
    fields*: seq[Field]
  ObjFields* = object of RootObj
    case kind*: ObjType
    of otEmpty:
      discard
    of otObj:
      fields*: seq[Field]
    of otVariant:
      common*: seq[Field]
      variants*: seq[NimVariant]
    of otEnum:
      vals*: seq[string]

proc empty(): ObjFields =
  ObjFields(kind: otEmpty)

proc getName*(f: Field): string =
  f.name

proc getT*(f: Field): NimNode =
  f.t

proc combine(a,b: ObjFields): ObjFields =
  proc noimpl() =
    raise newException(ValueError, fmt"No implementation for comparing {a.kind} and {b.kind}")

  case a.kind
  of otObj:
    case b.kind
    of otObj:
      result = ObjFields(kind: otObj, 
                        fields: concat(a.fields, b.fields))
    of otVariant:
      result = ObjFields(kind: otVariant,
                        common: concat(a.fields, b.common),
                        variants: b.variants)
    of otEnum:
      noimpl()
    of otEmpty:
      result = a
  of otVariant:
    case b.kind
    of otObj:
      result = ObjFields(kind: otVariant,
                         common: concat(b.fields, a.common),
                         variants: a.variants)
    of otVariant:
      noimpl()
    of otEnum:
      noimpl()
    of otEmpty:
      result = a
  of otEnum:
    case b.kind
    of otObj:
      noimpl()
    of otVariant:
      noimpl()
    of otEnum:
      result = ObjFields(kind: otEnum,
                         vals: concat(a.vals,b.vals))
    of otEmpty:
      result = a
  of otEmpty:
    result = b

proc combineAll(x: seq[ObjFields]): ObjFields =
  foldl(x, combine(a,b))

proc collectEnumVals(x: NimNode): seq[string] =
  case x.kind
  of nnkSym:
    result = @[x.strVal]
  of nnkEmpty:
    result = @[]
  else:
    error("Cannot collect enum vals from node ", x)

proc collectEnumFields(x: NimNode): ObjFields =
  expectKind(x, nnkEnumTy)
  let vs = collect:
    for c in x.children:
      collectEnumVals c
  let vals = concat(vs)
  return ObjFields(kind: otEnum, vals: vals)

proc collectObjFields(x: NimNode): ObjFields =
  proc foldChildren(x: NimNode): ObjFields =
    let r = collect:
      for c in x.children:
        collectObjFields(c)
    return combineAll(r)

  case x.kind
  of nnkIdent:
    return empty()
  of nnkEmpty:
    return empty()
  of nnkSym:
    return empty()
  of nnkIdentDefs:
    return ObjFields(
      kind: otObj,
      fields: @[Field(name: x[0].strVal, 
                      t: x[1])]
    )
  of nnkOfInherit:
    let parentClassSym = x[0]
    if parentClassSym.strVal == "RootObj":
      return empty()
    else:
      # echo "GOT INHERITANCE"
      return collectObjFields(parentClassSym.getImpl())
  of nnkRecList:
    return foldChildren(x)
  of nnkObjectTy:
    return foldChildren(x)
  of nnkTypeDef:
    return foldChildren(x)
  of nnkRefTy:
    return foldChildren(x)
  of nnkEnumTy:
    return collectEnumFields(x)
  of nnkRecCase:
    raise newException(ValueError, "No implementation for variants yet")
  else:
    raise newException(ValueError, "boo")

proc collectFields(x: NimNode): seq[Field] =
  proc recurseChildren(x: NimNode): seq[Field] =
    let r = collect:
      for c in x.children:
        collectFields(c)
    return concat(r)

  case x.kind
  of nnkIdent:
    return @[]
  of nnkIdentDefs:
    return @[Field(name: x[0].strVal, 
                   t: x[1])]
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
    error("Unknown NimNodeKind passed to collectFields", x)

proc collectFieldsForType*(t: NimNode): seq[Field] =
  expectKind(t, nnkTypeDef)
  collectFields(t)

proc collectObjFieldsForType*(t: NimNode): ObjFields =
  expectKind(t, nnkTypeDef)
  collectObjFields(t)