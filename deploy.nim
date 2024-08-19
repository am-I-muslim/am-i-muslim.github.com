import std/os


proc exec(cmd: string) =
  echo ">> ", cmd
  let r = execShellCmd cmd
  if r != 0:
    write stderr, "[STATUS CODE] = " & $r
    quit r

proc cp(src, dest: string) = 
  case src[^1]
  of '/', '\\': copyDir  src, dest
  else        : copyFile src, dest
  

when isMainModule:
  write stdout, "commit message (for main branch): "
  let msg = readLine stdin

  exec  "git add ."
  exec  "git commit -m \"" & msg & '"'
  exec  "git push"
  exec  "nimble dev"
  cp    "./dist/", "../dist/"
  exec  "git checkout pages"  
  cp    "../dist/", "./"
  exec  "git add ."  
  exec  "git commit -m \".\""  
  exec  "git push"  
  exec  "git checkout main"  
