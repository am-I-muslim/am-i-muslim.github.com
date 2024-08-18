import std/os


template cpdir(src, dest): untyped =
  copydir src, dest

template exec(cmd): untyped =
  echo ">> ", cmd
  discard execShellCmd cmd
  

when isMainModule:
  write stdout, "commit message (for main branch): "
  let msg = readLine stdin

  exec    "git add ."
  exec    "git commit -m \"" & msg & '"'
  exec    "git push"
  exec    "nimble dev"
  cpdir   "./dist", "../dist"
  exec     "git checkout pages"  
  cpdir   "../dist", "./"
  exec    "git add ."  
  exec    "git commit -m '.'"  
  exec    "git push"  
  exec    "git checkout main"  
