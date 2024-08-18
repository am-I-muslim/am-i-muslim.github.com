import std/os


template cpdir(src, dest): untyped =
  copydir src, dest

template exec(cmd): untyped =
  discard execShellCmd cmd
  

when isMainModule:
  exec    "nimble dev"
  copydir "./dist", "../dist"
  exec     "git checkout pages"  
  copydir "../dist", "./"
  exec    "git add ."  
  exec    "git commit -m '.'"  
  exec    "git push"  
  exec    "git checkout main"  
