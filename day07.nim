import
  std/algorithm,
  std/tables,
  std/strutils,
  std/sugar

type
  File = object
    name: string
    size: int

  Folder = object
    name: string
    files: seq[File]
    folders: seq[string]

proc parseInput(filename: string): Table[string, Folder] =
  var path: seq[string]
  var line: string
  var file = open(filename, fmRead)
  defer: file.close() 
  line = file.readLine()
  while not file.endOfFile:
    if line.startsWith("$ cd"):
      let newFolder = line.split[2]
      if newFolder != "..":
        path.add(newFolder)
      else:
        discard path.pop
      line = file.readLine
      continue
    if line == "$ ls":
      line = ""
      let curFolder = path.join("/")
      var folders: seq[string]
      var files: seq[File]
      while not (line.startsWith("$")):
        line = file.readLine
        if line.startsWith("dir"):
          folders.add((path & line.split[1]).join("/"))
        elif line.startsWith("$"):
          result[curFolder] = Folder(
            name: curFolder,
            files: files,
            folders: folders
          )
        elif file.endOfFile:
          if line.startsWith("dir"):
            folders.add(line.split[1])
          else:
            let parts = line.split
            files.add(File(name: parts[1], size: parseInt(parts[0])))
          result[curFolder] = Folder(
            name: curFolder,
            files: files,
            folders: folders
          )
          break
        else:
          let parts = line.split
          files.add(File(name: parts[1], size: parseInt(parts[0])))

proc getFilesizePerFolder(folders: Table[string, Folder]): Table[string, int] =
  for name, folder in folders.pairs:
    var total = 0
    for file in folder.files:
      total += file.size
    result[name] = total

proc getFolderSizes(folders: Table[string, Folder]): Table[string, int] =
  let filesizes = getFilesizePerFolder folders
  for name, folder in folders.pairs:
    var substack = folder.folders
    var total = filesizes[name]
    
    while substack.len > 0:
      let cur = substack.pop
      let curfolder = folders[cur]
      total += filesizes[curfolder.name]
      substack &= curfolder.folders

    result[name] = total

proc part1(folders: Table[string, Folder]) =
  let sizes = getFolderSizes folders
  var total = 0
  for name, size in sizes:
    if size <= 100000:
      total += size
  echo "Part1: ", total

proc part2(folders: Table[string, Folder]) =
  let sizes = getFolderSizes folders
  let spaceTotal = 70000000
  let free = spaceTotal - sizes["/"]
  let needed = 30000000 - free
  var candidates = collect:
    for _, size in sizes:
      if size >= needed: size
  candidates.sort
  echo "Part2: ", candidates[0]
  

if ismainmodule:
  let folders = parseInput("day7.txt")
  part1 folders
  part2 folders
