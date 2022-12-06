import
  std/packedsets

func firstUniqueRunOf(input: string, length: int): int =
  for i in (length - 1 ..< input.len):
    if input[i - length + 1 .. i].toPackedSet.len == length:
      return i + 1


proc part1(input: string) =
  echo "Part1: ", input.firstUniqueRunOf 4
    
proc part2(input: string) =
  echo "Part2: ", input.firstUniqueRunOf 14

if ismainmodule:
  let input = readFile("day6.txt")
  part1(input)
  part2(input)
