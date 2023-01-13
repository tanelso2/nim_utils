import
  nim_utils/simple_yaml

assert ofYaml(newYString("true"), bool) == true
assert ofYaml(newYString("false"), bool) == false