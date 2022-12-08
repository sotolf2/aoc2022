import
  std/algorithm,
  std/sets,
  std/sugar

type
  Point = tuple
    row, col: int

  Grid = seq[seq[int]]

  Direction = enum
    Row, Col, Wor, Loc

proc parseFile(filename: string): Grid =
  let file = open(filename, fmRead)
  defer: close file
  while not file.endOfFile:
    var curRow: seq[int]
    for ch in file.readLine:
      curRow.add(ch.ord - 48)
    result.add curRow

func seenRow(line: seq[int], num: int, direction: Direction): HashSet[Point] = 
  var maxSeen = -1
  for count, tree in line.pairs:
    if tree <= maxSeen:
      continue
    else:
      maxSeen = tree
      let curPoint = 
        case direction:
          of Row:
            (num, count)
          of Wor:
            (num, line.len - 1 - count)
          of Col:
            (count, num)
          of Loc:
            (line.len - 1 - count, num)
      result.incl curPoint

func allOf(length: int, num: int, direction: Direction): HashSet[Point] =
  for x in (0..<length):
    case direction:
      of Row, Wor:
        result.incl (num, x)
      of Col, Loc:
        result.incl (x, num)

func getScenicScore(grid: Grid, row, col: int): int =
  var up, left, right, down: int
  let 
    self = grid[row][col]
    leftRight = grid[row]
    upDown = collect:
      for rw in grid: rw[col]
  for i in countDown(col - 1, 0):
    up += 1
    if upDown[i] >= self:
      break
  for i in countUp(row + 1, leftRight.len - 1):
    right += 1
    if leftRight[i] >= self:
      break
  for i in countUp(col + 1, upDown.len - 1):
    down += 1
    if upDown[i] >= self:
      break
  for i in countDown(row - 1, 0):
    left += 1
    if leftRight[i] >= self:
      break
  up * right * down * left
  

proc part1(grid: Grid) =
  var seen = initHashSet[Point]()
  # first go through row-wise
  for rownum, row in grid.pairs:
    if rownum == 0 or rownum == grid.len - 1:
      seen.incl allOf(row.len, rownum, Row)
    else:
      seen.incl seenRow(row, rownum, Row)
      seen.incl seenRow(row.reversed, rownum, Wor)
  # then the colums
  for colNum in (0..<grid[0].len):
    if colNum == 0 or colNum == grid[0].len - 1:
      seen.incl allOf(grid[0].len, colNum, Col)
    else:
      let col = collect:
        for row in grid: row[colNum]
      seen.incl seenRow(col, colNum, Col)
      seen.incl seenRow(col.reversed, colNum, Loc)
  echo "Part1: ", seen.len

proc part2(grid: Grid) =
  var maxScore = 0
  for row in (0..<grid.len):
    for col in (0..<grid[0].len):
      let score = getScenicScore(grid, row, col)
      maxScore = max(score, maxScore)
  echo "Part2: ", maxScore

if ismainmodule:
  let grid = parseFile "day8.txt"
  part1 grid
  part2 grid
