import
  std/sets,
  std/strutils,
  std/sugar

type
  Point = tuple
    x, y: int
 
  Direction = enum
    Up, Down, Left, Right
  
  Command = tuple
    direction: Direction
    steps: int

proc parseFile(filename: string): seq[Command] =
  var file = open(filename, fmRead)
  defer: file.close
  while not file.endoffile:
    let parts = file.readLine.split()
    let direction =
      case parts[0]:
        of "U": Up
        of "D": Down
        of "L": Left
        of "R": Right
        else: quit(69)
    let steps = parts[1].parseInt
    result.add (direction, steps)

func toDelta(direction: Direction): Point =
  case direction:
    of Up: (0, 1)
    of Down: (0, -1)
    of Left: (-1, 0)
    of Right: (1, 0)

func `+`(self, other: Point): Point =
  (self.x + other.x, self.y + other.y)

func `-`(self, other: Point): Point =
  (self.x - other.x, self.y - other.y)

func `+=`(self: var Point, other: Point) =
  self.x += other.x
  self.y += other.y


proc adjustTowards(tail: var Point, head: Point) =
  let (dx, dy) = head - tail
  #dump (dx,dy)
  if dx.abs < 2 and dy.abs < 2: return
  if dx == 0 and dy == 2:
    tail.y += 1
  elif dx == 0 and dy == -2:
    tail.y -= 1
  elif dy == 0 and dx == 2:
    tail.x += 1
  elif dy == 0 and dx == -2:
    tail.x -= 1
  else:
    if dx > 0: tail.x += 1 else: tail.x -= 1
    if dy > 0: tail.y += 1 else: tail.y -= 1


proc moveStep(head, tail: var Point, direction: Direction): Point =
  head += direction.toDelta
  tail.adjustTowards head
  result = tail

proc moveStep(head: var Point, tails: var openArray[Point], direction: Direction): Point =
  head += direction.toDelta
  var last = head
  for i in (0..<tails.len):
    tails[i].adjustTowards last
    last = tails[i]
  result = last
  #dump result

proc execute(command: Command, head, tail: var Point): HashSet[Point] =
  var (direction, amount) = command
  for i in (1..amount):
    result.incl moveStep(head, tail, direction)
    #dump (head,tail)

proc execute(command: Command, head: var Point, tails: var openarray[Point]): HashSet[Point] =
  var (direction, amount) = command
  #dump command
  for i in (1..amount):
    result.incl moveStep(head, tails, direction)

proc part1(commands: seq[Command]) =
  var 
    head = (0,0)
    tail = (0,0)
    tailed = initHashSet[Point]()
  for command in commands:
    #dump command
    tailed.incl command.execute(head, tail)
    #dump tailed
  echo "Part1: ", tailed.len

proc part2(commands: seq[Command]) =
  var
    head = (0,0)
    knots: array[9, Point]
    tailed = initHashSet[Point]()
  for i in (0..<knots.len):
    knots[i] = (0,0)
  for command in commands:
    tailed.incl command.execute(head, knots)
  echo "Part2: ", tailed.len

if ismainmodule:
  let commands = "day9.txt".parseFile
  part1 commands
  part2 commands
