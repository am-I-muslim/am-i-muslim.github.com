import std/os


proc exec(cmd: string) =
  echo ">> ", cmd
  let r = execShellCmd cmd
  if r != 0:
    write stderr, "[STATUS CODE] = " & $r
    quit r
  

when isMainModule:
  write stdout, "commit message (for main branch): "
  let msg = readLine stdin

  exec      "git add ."
  exec      "git commit -m \"" & msg & '"'
  exec      "git push"
  exec      "nimble dev"
  copydir   "./dist", "../dist"
  exec      "git checkout pages"  
  copydir   "../dist", "./"
  exec    "git add ."  
  exec    "git commit -m \".\""  
  exec    "git push"  
  exec    "git checkout main"  
