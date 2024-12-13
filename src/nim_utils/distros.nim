import
    options,
    os,
    osproc,
    sequtils,
    strformat,
    strutils,
    tables,
    ./logline,
    ./shell_utils

const osReleaseFile = "/etc/os-release"

var osInfo: TableRef[string, string]

proc getOSInfo*(): TableRef[string,string] =
  if osInfo != nil:
    return osInfo
  result = newTable[string,string]()
  if osReleaseFile.fileExists:
    for l in osReleaseFile.lines:
        let x = l.split("=")
        if len(l) > 1:
           let k = x[0]
           let v = x[1]
           result[k] = v
    osInfo = result

template id(): string =
  getOSInfo().getOrDefault("ID", "")

template idLike(): string =
  getOSInfo().getOrDefault("ID_LIKE", id())


type
  PackageManager* = enum
    pmApt = "apt-get",
    pmNix = "nix-env",
    pmPacman = "pacman",
    pmYay = "yay",
    pmYum = "yum"

proc exeName(p: PackageManager): string = $p

proc getPackageManager*(): Option[PackageManager] =

  template tryReturn(x: PackageManager) =
    if exeExists(x.exeName):
      return some(x)

  # tryReturn pmNix
  let idL = idLike()
  if "debian" in idL:
      tryReturn pmApt
  if "arch" in idL:
      tryReturn pmYay
      tryReturn pmPacman
  none(PackageManager)

proc installCmd(pm: PackageManager, pkg: string): string =
  case pm:
    of pmApt:
      fmt"sudo {pm} install -y {pkg}"
    of pmNix:
      fmt"nix-env -i {pkg}"
    of pmYay, pmPacman:
      fmt"sudo {pm} -S {pkg}"
    else:
      raise newException(ValueError, "NOT-IMPLEMENTED")

proc updateCmd(pm: PackageManager): string =
  case pm:
    of pmApt:
      fmt"sudo {pm} update"
    of pmYay, pmPacman:
      fmt"sudo {pm} -Sy"
    else:
      raise newException(ValueError, "NOT-IMPLEMENTED")

proc installPackage*(n: string) =
  let pm = getPackageManager().get()
  discard execCmd pm.installCmd(n)

proc installPackages*(pkgs: seq[string]) =
  # Hacky
  let s = pkgs.join(" ")
  installPackage(s)

proc updatePackageList*() =
  let pm = getPackageManager().get()
  discard execCmd pm.updateCmd()

when isMainModule:
  echo idLike()
  let pm = getPackageManager().get()
  echo pm.updateCmd()
