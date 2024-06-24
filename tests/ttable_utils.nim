import
  std/tables,
  unittest,
  nim_utils/table_utils

suite "table_utils":
  test "& - basic - Table":
    let x = {1:2,3:4}.toTable
    let y = x & {5:6}.toTable
    check(len(y) == 3)
    check(y[1] == 2)
    check(y[3] == 4)
    check(y[5] == 6)
  test "& - basic - TableRef":
    let x = {1:2,3:4}.newTable
    let y = x & {5:6}.newTable
    check(len(y) == 3)
    check(y[1] == 2)
    check(y[3] == 4)
    check(y[5] == 6)
  test "& - overwrite - Table":
    let x = {1:2}.toTable
    let y = x & {1:3}.toTable
    check(len(y) == 1)
    check(y[1] == 3)
  test "& - overwrite - TableRef":
    let x = {1:2}.newTable
    let y = x & {1:3}.newTable
    check(len(y) == 1)
    check(y[1] == 3)
