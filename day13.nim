import
  std/algorithm,
  std/strutils,
  std/sugar

type
  ItemType = enum
    kList, kInt
  Item = ref object
    case kind: ItemType:
      of kList: subList: List
      of kInt: intVal: int
  List = seq[Item]
  Pair = tuple
    left: List 
    right: List 

proc `$`(self: Item): string =
  case self.kind: 
    of kList:
      $self.subList
    of kInt:
      $self.intVal

proc parseItem(input: string): (Item, string) =
  var 
    itemstr: string
    rest: string
    commaIdx = input.find(',')
    bracketIdx = input.find(']')
  if commaIdx == -1 and bracketIdx == -1:
    itemstr = input
    rest = ""
  elif commaIdx == -1:
    itemstr = input[0..<bracketIdx]
    rest = input[bracketIdx..^1]
  elif bracketIdx == -1:
    itemstr = input[0..<commaIdx]
    rest = input[commaIdx + 1..^1]
  else:
    if bracketIdx < commaIdx:
      itemstr = input[0..<bracketIdx]
      rest = input[bracketIdx..^1]
    else:
      itemstr = input[0..<commaIdx]
      rest = input[commaIdx + 1..^1]
  let item = Item(kind: kInt, intVal: itemstr.parseInt)
  return (item, rest)


proc parseList(input: string): (Item, string) =
  var 
    list: seq[Item]
    item: Item
    liststr = input
    rest: string
  while liststr.len > 0:
    if liststr.startsWith("["):
      (item, liststr) = parseList liststr[1..^1]
      list.add item
    elif liststr.startsWith ",":
      liststr = liststr[1..^1]
    elif liststr.startsWith "]":
      rest = liststr[1..^1]
      let obj = Item(kind: kList, subList: list)
      return (obj, rest)
    else:
      (item, liststr) = parseItem liststr
      list.add item

proc parseLine(lineIn: string): List =
  var 
    line = lineIn
    item: Item
  line = line[1..^2]
  while line.len > 0:
    if line.startsWith "[":
      (item, line) = parseList line[1..^1]
      result.add item
    elif line.startsWith ",":
      line = line[1..^1]
    else:
      (item, line) = parseItem line
      result.add item
      
proc parseFile(filename: string): seq[Pair] =
  let lines = filename.readFile.split("\n")
  var 
    left: List
    right: List
    didLeft = false
  for line in lines:
    if line == "":
      result.add (left, right)
    elif didLeft:
      right = parseLine line
      didLeft = false
    else:
      left = parseLine line
      didLeft = true

proc `<`(left: List, right: List): bool 
proc `<`(a: Item, b: Item): bool =
  if a.kind == kInt and b.kind == kInt:
    a.intVal < b.intval
  elif a.kind == kList and b.kind == kList:
    a.subList < b.subList
  elif a.kind == kList and b.kind == kInt:
    a.sublist < @[Item(kind: kInt, intval: b.intVal)]
  else:
    @[Item(kind: kInt, intval: a.intval)] < b.sublist

proc `<`(left: List, right: List): bool =
  var itemNum: int
  while itemNum < left.len and itemNum < right.len:
    if left[itemNum] < right[itemNum]:
      return true
    elif right[itemnum] < left[itemNum]:
      return false
    else:
      itemNum += 1
    
  return left.len < right.len


proc part1(signals: seq[Pair]) =
  var sum = 0
  for i, pair in signals:
    if pair.left < pair.right:
      sum += (i + 1)
  echo "Part1: ", sum

proc part2(signals: seq[Pair]) =
  var allPackets: seq[List]
  let divider1 = parseLine"[[2]]"
  let divider2 = parseLine"[[6]]"
  for (left, right) in signals:
    allPackets.add left
    allPackets.add right
  allpackets.add divider1
  allPackets.add divider2
  allpackets.sort
  let 
    div1Loc = allPackets.find(divider1) + 1
    div2Loc = allPackets.find(divider2) + 1

  echo "Part2: ", div1Loc * div2Loc

if isMainModule:
  let signals = "day13.txt".parseFile
  #echo signals
  part1 signals
  part2 signals
