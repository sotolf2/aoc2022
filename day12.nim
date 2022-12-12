import
  std/heapqueue,
  std/tables,
  std/sugar

type
  Grid = seq[seq[int]]
  Point = tuple
    row, col: int
  Position = tuple
    point: Point
    cost: int

proc `<`(a, b: Position): bool = a.cost < b.cost
proc `+`(a, b: Point): Point = (a.row + b.row, a.col + b.col)

proc parseFile(filename: string): (Grid, (Point, Point)) =
  let file = open(filename, fmRead)
  defer: file.close
  var row: int
  result[0].add @[]
  while not file.endOfFile:
    let cur = file.readChar
    if cur == '\n': 
      row += 1
      result[0].add @[]
    else:
      case cur:
        of 'S':
          result[1][0] = (row, len(result[0][row]))
          result[0][row].add(0)
        of 'E': 
          result[1][1] = (row, len(result[0][row]))
          result[0][row].add(26)
        else: result[0][row].add cur.ord - 97

func `in`(cur: Point, map: Grid): bool =
  cur.row >= 0 and cur.row < (map.len - 1) and
  cur.col >= 0 and cur.col < (map[0].len)

func cost(map: Grid, current, next: Point): int =
  map[next.row][next.col] - map[current.row][current.col]

func neighbours(map: Grid, cur: Point): seq[Point] =
  var candidates: seq[Point]
  candidates.add cur + (-1, 0)
  candidates.add cur + (0, 1)
  candidates.add cur + (1, 0)
  candidates.add cur + (0, -1)

  for candidate in candidates:
    if candidate in map:
      if cost(map, cur, candidate) <= 1:
        result.add candidate


func traceRoute(path: Table[Point, Point], start, goal: Point): seq[Point] =
  var current = goal
  if current not_in path:
    return @[]
  while true:
    result.add current
    if current == start: break
    current = path[current]

func dijkstra(map: Grid, start, goal: Point): seq[Point] =
  var frontier = initHeapQueue[Position]()
  frontier.push (start, map[start.row][start.col])
  var comeFrom = initTable[Point, Point]()
  var costSoFar = initTable[Point, int]()
  costSoFar[start] = 0

  while frontier.len > 0:
    let current = frontier.pop.point

    if current == goal:
      break
    
    for next in map.neighbours current:
      let newCost = costSoFar[current] + 1
      if next notIn costSoFar or newCost < costSoFar[next]:
        costSoFar[next] = newCost
        frontier.push (next, newCost)
        comeFrom[next] = current
  
  result = comeFrom.traceroute(start, goal)

proc findPossibleStarts(map: Grid): seq[Point] =
  for rownum, row in map:
    for colnum, val in row:
      if val == 0:
        result.add (rownum, colnum)

proc part1(map: Grid, startGoal: (Point, Point)) =
  let (start, goal) = startGoal
  let path = dijkstra(map, start, goal)
  echo "Part1: ", path.len - 1

proc part2(map: Grid, startGoal: (Point, Point)) =
  let (start, goal) = startGoal
  let startCandidates = findPossibleStarts(map)
  var minSteps = 521
  for candidate in startCandidates:
    let path = dijkstra(map,candidate, goal)
    let length = path.len - 1
    if minSteps > length and length > 0:
      minSteps = length

  echo "Part2: ", minSteps


if isMainModule:
  let (map, startGoal) = "day12.txt".parsefile
  part1(map, startGoal)
  part2(map, startGoal)
