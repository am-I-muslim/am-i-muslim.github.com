import std/[random]
import std/[dom, jsffi, cstrutils]

import ./[utils]

# -----------------------------------------

type
  Env* = ref object
    timerId*: TimeOut
    ind*      = 0
    wait*     = 0


proc mockKeyboardTypeStep(el: Element, text: cstring,  i: Natural, isLast: bool) =
  template eh: untyped = el.innerHTML
    
  let
    ch      = text.charat i
    postfix = 
      if (not isLast) and isContinousPersianChar ch: persianJunctionC
      else:                                          emptyC
    curr = 
      if eh.endsWith persianJunctionC: eh.substr(0, eh.len - 1)
      else:                            eh 

  eh = curr & ch & postfix

proc mockKeyboardType*(env: Env, el: Element, tolerance: int, text: cstring) =
  proc impl =

    if 0 < env.wait:
      dec env.wait
      env.timerid = setTimeout(impl, rand 0 .. tolerance)
  
    else:
      mockKeyboardTypeStep el, text, env.ind, (env.ind == text.len-1) or not (isPersianChar text.charAt env.ind+1)
      inc env.ind

      if (text.charAt env.ind) == spaceC:
        env.wait = rand 0 .. 2
  
      if env.ind < text.len:
        env.timerid = setTimeout(impl,  rand 0 .. tolerance)

  env.wait = rand 3 .. 8
  impl()

