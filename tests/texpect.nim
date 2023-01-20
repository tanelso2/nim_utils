import
  nim_utils/expect,
  macros

expandMacros:
  expectTest:
    echo "Hello" 
    expect """Hello2"""

