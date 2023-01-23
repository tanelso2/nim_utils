import
  nim_utils/io_utils,
  nim_utils/logline,
  unittest

proc checkBoxTrim(a,b: string) =
  check (boxTrim a) == (boxTrim b)

proc checkBoxTrimNotEquals(a,b: string) =
  check (boxTrim a) != (boxTrim b)

let x = boxTrim """
  abc
"""

check x == "abc"

let y = boxTrim """

  abc
"""

check y == "abc"

checkBoxTrim(y, "abc")

checkBoxTrim("""
  

  abc
""", """
        abc
""")

checkBoxTrimNotEquals("""
  
  a
  abc
""", """
        abc
""")

checkBoxTrimNotEquals("""
  
  
  abc
""", """
        abc1
""")

checkBoxTrimNotEquals("""
  
  
  ab c
""", """
        abc
""")