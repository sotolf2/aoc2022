import
  std/algorithm,
  std/deques,
  std/strutils,
  std/sugar

type 
  Op = enum
    Multiply, Add, Square

  Monkey = object
    items: Deque[int]
    op: (Op, int)
    divTest: int
    yes: int
    no: int
    monkeyBusiness: int

proc parseMonkey(input: string): Monkey =
  let lines = input.split("\n") 
  
  # Parse starting items
  let itemLine = lines[1].strip
  let itemParts = itemline.split ':'
  let strs = itemParts[1].split ','
  for item in strs:
    result.items.addLast (parseInt item.strip)

  # Parse operation
  var operationLine = lines[2].strip
  operationLine.removePrefix "Operation: new = old "
  let opParts = operationLine.split
  if operationLine == "* old":
    result.op = (Square, 0)
  else:
    let op = 
      case opParts[0]: 
       of "*": Multiply 
       of "+": Add 
       else: quit(69)
    let opVal = parseInt opParts[1]
    result.op = (op, opVal)

  # Parse test
  let testLine = lines[3].strip
  result.divTest = parseInt testLine.split[^1]

  # test True
  let trueLine = lines[4].strip
  result.yes = parseInt trueLine.split[^1]

  # test False
  let falseLine = lines[5].strip
  result.no = parseInt falseLine.split[^1]

proc parseFile(filename: string): seq[Monkey] =
  let 
    content = readFile(filename)
    monkies = content.split("\n\n")

  for monkey in monkies:
    result.add (parseMonkey monkey)

proc eval(operation: (Op, int), item: var int) =
  let (op, val) = operation
  case op:
    of Add: item += val
    of Multiply: item *= val
    of Square: item *= item

proc round(monkies: var seq[Monkey]) =
  for cur in 0 ..< monkies.len:
    while monkies[cur].items.len > 0:
      # grab item
      var item = monkies[cur].items.popFirst()

      # Inspect item Nervousness increases
      monkies[cur].op.eval item

      # monkeyBusiness increases
      monkies[cur].monkeyBusiness += 1

      # Monkey got bored relief
      item = item div 3

      # Where to throw?
      if item mod monkies[cur].divTest == 0:
        monkies[monkies[cur].yes].items.addLast(item)
      else:
        monkies[monkies[cur].no].items.addLast(item)

proc round2(monkies: var seq[Monkey], modulator: int) =
  for cur in 0 ..< monkies.len:
    while monkies[cur].items.len > 0:
      # grab item
      var item = monkies[cur].items.popFirst()

      # Inspect item Nervousness increases
      monkies[cur].op.eval item

      # monkeyBusiness increases
      monkies[cur].monkeyBusiness += 1

      # There is no relief!
      item = item mod modulator

      # Where to throw?
      if item mod monkies[cur].divTest == 0:
        monkies[monkies[cur].yes].items.addLast(item)
      else:
        monkies[monkies[cur].no].items.addLast(item)

proc part1(monkiesIn: seq[Monkey]) =
  var monkies = monkiesIn
  for r in 1..20:
    monkies.round
    
  var monkeyBusiness: seq[int]
  for monkey in monkies:
    monkeyBusiness.add monkey.monkeyBusiness
  sort monkeyBusiness
  let total = monkeyBusiness[^1] * monkeyBusiness[^2]
  echo "Part1: ", total

proc part2(monkiesIn: seq[Monkey]) =
  var monkies = monkiesIn
  var monkeyBusiness: seq[int]
  var modulator = 1
  for monkey in monkies:
    modulator *= monkey.divTest

  for r in 1..10000:
    monkies.round2 modulator

  for monkey in monkies:
    monkeyBusiness.add monkey.monkeyBusiness
  sort monkeyBusiness
  let total = monkeyBusiness[^1] * monkeyBusiness[^2]
  echo "Part2: ", total

if isMainModule:
  let monkies = parseFile "day11.txt"
  part1 monkies
  part2 monkies
