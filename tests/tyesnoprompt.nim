discard """
  input: '''y
            n
            Y
            N
            b
            y
  '''
"""

import
  nim_utils/cli

assert yesNoPrompt("")
assert not yesNoPrompt("")
assert yesNoPrompt("")
assert not yesNoPrompt("")
assert yesNoPrompt("")

