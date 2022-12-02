import
  std/strutils,
  std/tables

type
  Match = tuple
    other: char
    you: char

  Plan = seq[Match]

  Item = enum
    Rock
    Paper
    Scissors

  Result = enum
    Win
    Lose
    Draw

  Strategy = Table[char, Item]


proc parse_file(filename: string): Plan =
  let contents = readFile filename
  for line in contents.strip.split "\n":
    if line.len > 2:
      result.add (line[0], line[2])

func decrypt(match: Match, strat: Strategy): (Item, Item) =
  (strat[match.other], strat[match.you])

func matchScore(other, you: Item): int =
  if you == other: return 3
  case you
    of Rock:
      case other:
        of Rock: return 3
        of Paper: return 0
        of Scissors: return 6
    of Paper:
      case other:
        of Rock: return 6
        of Paper: return 3
        of Scissors: return 0
    of Scissors:
      case other:
        of Rock: return 0
        of Paper: return 6
        of Scissors: return 3

func judge(plan: Plan, strat: Strategy): int =
  for match in plan:
    let (other, you) = match.decrypt strat
    case you:
      of Rock: result += 1
      of Paper: result += 2
      of Scissors: result += 3
    result += matchScore(other, you)

func judge2(plan: Plan): int =
  for match in plan:
    let 
      (otherChar, youChar) = match
      other =
        case otherChar:
          of 'A': Rock
          of 'B': Paper
          of 'C': Scissors
          else: return 0
      wantedResult =
        case youChar:
          of 'X': Lose
          of 'Y': Draw
          of 'Z': Win
          else: return 0
      you =
        case other:
          of Rock:
            case wantedResult:
              of Win: Paper
              of Draw: Rock
              of Lose: Scissors
          of Paper:
            case wantedResult:
              of Win: Scissors
              of Draw: Paper
              of Lose: Rock
          of Scissors:
            case wantedResult:
              of Win: Rock
              of Draw: Scissors
              of Lose: Paper
    case wantedResult:
      of Win: result += 6
      of Draw: result += 3
      of Lose: result += 0

    case you:
      of Rock: result += 1
      of Paper: result += 2
      of Scissors: result += 3
          

proc part1(plan: Plan) =
  var strat: Strategy
  strat['A'] = Rock
  strat['B'] = Paper
  strat['C'] = Scissors
  strat['X'] = Rock
  strat['Y'] = Paper
  strat['Z'] = Scissors

  let score = judge(plan, strat)
  echo "Part1: ", score

proc part2(plan: Plan) =
  let score = judge2 plan
  echo "Part2: ", score


if ismainmodule:
  let plan = parse_file "day2.txt"
  part1 plan
  part2 plan
