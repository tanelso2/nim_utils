import
  nim_utils/expect,
  macros

expectTest:
  echo "Hello" 
  expect """
    Hello
  """

  echo "Hello2"
  expect """
    Hello2
  """

  for i in 1..5:
    echo i
  expect """
    1
    2
    3
    4
    5
  """

