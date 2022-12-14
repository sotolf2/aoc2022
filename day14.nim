import
  std/tables,
  std/strutils,
  std/sugar

type
  Point = tuple
    row, col: int
  Item = enum
    Rock, Sand

proc parseFile(filename: string): Table[Point, Item] =
  let lines = readFile(filename).strip.splitLines
  for line in lines:
    let parts = line.split(" -> ")
    let points = collect:
      for part in parts:
        let rowCol = part.split(',')
        (rowCol[0].parseInt, rowCol[1].parseInt)
    for idx in 0 ..< points.len - 1:
      let
        first: Point = points[idx]
        second: Point = points[idx+1]
      if first.row == second.row:
        for col in min(first.col, second.col)..max(first.col, second.col):
          result[(first.row, col)] = Rock
      if first.col == second.col:
        for row in min(first.row, second.row)..max(first.row, second.row):
          result[(row, first.col)] = Rock

proc `$`(self: Table[Point, Item]): string =
  for key in self.keys():
    result &= $key 
    result &= ": "
    result &= $self[key] 
    result &= "\n"

proc getLowestRock(area: Table[Point, Item]): int =
  let cols = collect:
    for key in area.keys:
      key.col
  max cols

func `+`(self, other: Point): Point =
  (self.row + other.row, self.col + other.col)

proc `+=`(self: var Point, other: Point) =
  self.row += other.row
  self.col += other.col

proc dropPiece(area: var Table[Point,Item], dropPoint: Point, lowestRock: int): bool =
  var cur = dropPoint
  while cur.col <= lowestRock:
    if cur + (0,1) in area:
      if cur + (-1, 1) in area:
        if cur + (1,1) in area:
          area[cur] = Sand
          return true
        else:
          cur += (1,1)
      else:
        cur += (-1, 1)
    else:
      cur += (0,1)

proc dropSand(area: var Table[Point,Item], dropPoint: Point, lowestRock: int): int =
  while dropPiece(area, dropPoint, lowestRock):
    result += 1

proc dropPiece(area: var Table[Point,Item], dropPoint: Point, lowestRock, floor: int): bool =
  var cur = dropPoint
  while cur.col < lowestRock:
    if cur + (0,1) in area:
      if cur + (-1, 1) in area:
        if cur + (1,1) in area:
          area[cur] = Sand
          if cur != dropPoint:
            return true
          else:
            return false
        else:
          cur += (1,1)
      else:
        cur += (-1, 1)
    else:
      cur += (0,1)
  if cur + (0,1) in area:
    if cur + (-1, 1) in area:
      if cur + (1,1) in area:
        area[cur] = Sand
        return true
      else:
        cur += (1,1)
        area[cur] = Sand
        return true
    else:
      cur += (-1, 1)
      area[cur] = Sand
      return true
  else:
    cur += (0,1)
    area[cur] = Sand
    return true


proc dropSand(area: var Table[Point,Item], dropPoint: Point, lowestRock: int, floor: int): int =
  while dropPiece(area, dropPoint, lowestRock, floor):
    result += 1

proc part1(area: Table[Point, Item]) =
  let lowestRock = getLowestRock(area)
  var map = area
  let restingSand = dropSand(map, (500, 0), lowestRock)
  echo "Part1: ", restingSand

proc part2(area: Table[Point, Item]) =
  let lowestRock = getLowestRock(area)
  echo lowestRock
  var map = area
  let restingSand = dropSand(map, (500,0), lowestRock, lowestRock + 1)
  echo "Part2: ", restingSand + 1
  #echo map

if isMainModule:
  let area = "day14.txt".parseFile
  part1 area
  part2 area
