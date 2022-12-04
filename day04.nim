import
  std/packedsets,
  std/sequtils,
  std/strutils,
  std/with

type
  Range = tuple
    start: int
    stop: int

  SectionPair = tuple
    first: Range
    second: Range

proc parseRange(inn: string): Range =
  let parts = inn.split '-'
  with result:
    start = parseInt parts[0]
    stop = parseInt parts[1]

proc parseFile(filename: string): seq[SectionPair] =
  let file = open(filename)
  defer: close(file)

  for line in lines(file):
    if line.len < 5:
      return
    let parts = line.split ','
    var section: SectionPair
    with section:
      first = parseRange parts[0]
      second = parseRange parts[1]
    result.add section

func contains(self, other: Range): bool =
  self.start <= other.start and self.stop >= other.stop

func toPackedSet(self: Range): PackedSet[int] =
  (self.start..self.stop).toSeq.toPackedSet()

func overlaps(self, other: Range): bool =
  intersection(
    self.toPackedSet,
    other.toPackedSet
  ).len > 0

proc part1(sections: seq[SectionPair]) =
  var count = 0
  for section in sections:
    let 
      first = section.first
      second = section.second
    if (first.contains second) or (second.contains first):
      count += 1

  echo "Part 1: ", count
      
proc part2(sections: seq[SectionPair]) =
  var count = 0
  for section in sections:
    if section.first.overlaps section.second:
      count += 1

  echo "Part 2: ", count

if ismainmodule:
  let sectionPairs = parseFile("day4.txt")
  part1 sectionPairs
  part2 sectionPairs
