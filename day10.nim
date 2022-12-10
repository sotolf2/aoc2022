import
  std/sugar,
  std/strutils

type
  Op = enum
    AddX, Noop

  Program = seq[(Op, int)]

proc parseFile(filename: string): Program =
  let file = open(filename, fmRead)
  defer: file.close

  while not file.endOfFile:
    let
      line = file.readLine
      parts = line.split
      op = case parts[0]:
        of "noop":
          Noop
        of "addx":
          AddX
        else:
          quit(69)
      value = if len(parts) > 1: parts[1].parseInt else: 0
    result.add (op, value)

proc part1(program: Program) =
  var 
    register = 1
    cycle = 1
    interestingValues: seq[(int, int)]
    totalSignalStrength: int
  let interestingCycles = [20, 60, 100, 140, 180, 220]
  for (op, val) in program:
    case op:
      of Noop:
        if cycle in interestingCycles:
          interestingValues.add (cycle, register)
        cycle += 1
        continue
      of AddX:
        if cycle in interestingCycles:
          interestingValues.add (cycle, register)
        cycle += 1
        if cycle in interestingCycles:
          interestingValues.add (cycle, register)
        cycle += 1
        register += val
  if cycle in interestingCycles:
    interestingValues.add (cycle, register)

  for (cycle, reg) in interestingValues:
    totalSignalStrength += (cycle * reg)

  echo "Part1: ", totalSignalStrength

proc show(screen: array[241, bool]) =
  let
    height = 6
    width = 40
  for y in 0 ..< height:
    for x in 1 .. width:
      #dump y*width+x
      stdout.write if screen[y*width+x]: "#" else: "."
    stdout.write "\n"

proc update(screen: var array[241, bool], cycle, register: int) =
  let sprite = register + 1
  if cycle mod 40 in (sprite - 1 .. sprite + 1):
    screen[cycle] = true

proc part2(program: Program) =
  var 
    crt: array[241, bool]
    cycle = 1
    register = 1

  for (op, val) in program:
    case op:
      of Noop:
        crt.update(cycle, register)
        cycle += 1
        continue
      of AddX:
        crt.update(cycle, register)
        cycle += 1
        crt.update(cycle, register)
        cycle += 1
        register += val

  crt.show

if ismainmodule:
  let program = "day10.txt".parseFile
  part1 program
  part2 program
