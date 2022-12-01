import
  std/algorithm,
  std/math,
  std/parseutils,
  std/strutils

proc parseFile(filename: string): seq[seq[int]] =
  let 
    content = readfile(filename)
    elves = content.split "\n\n"
  for elf in elves:
    var calories: seq[int]
    for food in elf.strip.split "\n":
      calories.add parseInt(food)
    result.add calories

proc part1(elves: seq[seq[int]]) =
  var maxcal = 0
  for elf in elves:
    if elf.sum > maxcal:
      maxcal = elf.sum
  
  echo "part1: ", maxcal

proc part2(elves: seq[seq[int]]) =
  var top3: array[3, int]

  for elf in elves:
    top3.sort 
    let total = sum elf
    if total > top3[0]:
      top3[0] = total

  echo "part2: ", top3.sum

if isMainModule:
  let elves = parseFile("day1.txt")
  part1 elves
  part2 elves
