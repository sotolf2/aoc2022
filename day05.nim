import
  std/strutils

type
  Stacks = seq[seq[char]]

proc findStackPositions(line: string): seq[int] =
  for idx, ch in line.pairs:
    if ch != ' ':
      result.add(idx)

proc parseStacks(lines: seq[string]): Stacks =
  let stackPos = findStackPositions(lines[^1])

  for stack in 0..<stackPos.len:
    result.add(@[])

  for i in countDown(lines.len-2,0):
    for idx, j in stackPos.pairs:
      if lines[i][j] != ' ':
        result[idx].add(lines[i][j]) 
    
proc parseInput(filename: string): (Stacks, seq[string]) =
  let text = readFile(filename)
  let parts = text.split("\n\n")
  result[0] = parseStacks(parts[0].split("\n"))
  result[1] = parts[1].strip.split("\n")

proc parseCommand(line: string): (int, int, int) =
  let words = line.split(" ") 
  result[0] = words[1].parseInt
  result[1] = words[3].parseInt
  result[2] = words[5].parseInt

proc part1(inStacks: Stacks, commands: seq[string]) =
  var stacks = inStacks
  for command in commands:
    let (mv, frm, to) = parseCommand(command)
    for _ in (0..<mv):
      let val = stacks[frm-1].pop
      stacks[to-1].add(val)
  
  var tops: seq[char]
  for stack in stacks:
    tops.add(stack[^1])

  echo "Part1: ", tops.join("")

proc part2(inStacks: Stacks, commands: seq[string]) =
  var 
    stacks = inStacks
    holding: seq[char]
  for command in commands:
    let (mv, frm, to) = parseCommand(command)
    for _ in (0..<mv):
      holding.add(stacks[frm-1].pop)
    
    while holding.len > 0:
      stacks[to-1].add(holding.pop)

  var tops: seq[char]
  for stack in stacks:
    tops.add(stack[^1])

  echo "Part2: ", tops.join("")

if ismainmodule:
  let (stacks,commands) = parseInput("day5.txt")
  part1(stacks, commands)
  part2(stacks, commands)
