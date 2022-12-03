import 
  std/packedsets,
  std/strutils
  #std/sugar

proc compartments(self: string): (string, string) =
  let mid = self.len div 2
  result[0] = self[0..<mid]
  result[1] = self[mid..^1]

proc parseFile(filename: string): seq[string] = 
  filename.readfile().strip().split()

func priority(item: char): int =
  if item.isUpperAscii:
    item.ord - 64 + 26
  else:
    item.ord - 96

proc part1(backpacks: seq[string]) =
  var sum: int
  for backpack in backpacks:
    let 
      (first, second) = backpack.compartments
      firstSet = first.toPackedSet
      secondSet = second.toPackedSet
      commons = $intersection(firstSet, secondSet)
      common = commons[1]
    sum += common.priority

  echo "Part1: ", sum

proc part2(backpacks: seq[string]) =
  let groupsize = 3
  var sum: int
  var group: seq[string]
  for i, backpack in backpacks.pairs:
    if i mod groupsize == groupsize - 1:
      group.add backpack
      var set = group[0].toPackedSet
      for cur in group[1..^1]:
        set = set.intersection(cur.toPackedSet)
      for item in set:
        sum += item.priority
      group = @[]
    else:
      group.add backpack

  echo "Part2: ", sum

if isMainModule:
  let backpacks = parseFile "day3.txt"
  part1 backpacks
  part2 backpacks
