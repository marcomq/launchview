import osproc, strutils, browsers, json, tables, streams, threadpool
import nimview

var replacements = newSeq[(string, string)]()
var pipes = newTable[int, Process]()

proc replacePlaceHolders(input: string): string =
  {.cast(gcsafe).}:
    result = input.multiReplace(replacements)

proc terminatePipe(id: int) = 
  {.cast(gcsafe).}:
    if id in pipes:
      pipes[id].terminate()
      discard pipes[id].waitForExit()

proc createPipe(cmd: string, id: int) = 
  {.cast(gcsafe).}:
    pipes[id] = startProcess(cmd, options={poEvalCommand})
    for line in pipes[id].lines:
      echo "-" & line
      callJs("feedback", $ %*{"id": id, "value": line})
    discard pipes[id].waitForExit()
    pipes[id].close()

when isMainModule:
  add "sendToShell", proc (value :string, id: int) =
    var input = pipes[id].inputStream
    input.write(value)

  add "execShellCmd", proc (cmd: string, id: int) =
      ## TODO: this function is not preventing CLI injection 
      let replacedCmd = replacePlaceHolders(cmd)
      terminatePipe(id)
      createPipe(replacedCmd, id)
  add "openBrowser", proc (url: string) =
    openDefaultBrowser(replacePlaceHolders(url))
  enableStorage() # adds getStoredVal and setStoredVal
  start()