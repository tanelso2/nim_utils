discard """
  input: "y\nn\nY\nN\nb\ny"
"""

import
  nim_utils/cli

assert yesNoPrompt("")
assert not yesNoPrompt("")
assert yesNoPrompt("")
assert not yesNoPrompt("")
assert yesNoPrompt("")

