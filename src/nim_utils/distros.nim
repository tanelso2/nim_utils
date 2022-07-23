import
    options,
    os,
    osproc,
    sequtils,
    strformat,
    strutils,
    tables,
    nim_utils/shell_utils

const osReleaseFile = "/etc/os-release"

proc getOSInfo(): Table[string,string] =
  result = initTable[string,string]()
  if osReleaseFile.fileExists:
    let osInfoStr = readFile(osReleaseFile)
    for l in osInfoStr.split("\n"):
        let x = l.split("=")
        if len(l) > 1:
           let k = x[0]
           let v = x[1]
           result[k] = v

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

  template tryReturn(x: PackageManager): typed =
    if exeExists(x.exeName):
      return some(x)

  # tryReturn pmNix
  case idLike():
    of "debian":
      tryReturn pmApt
    of "arch":
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
  let osInfo = getOSInfo()
  let pm = getPackageManager().get()
  echo pm.updateCmd()
