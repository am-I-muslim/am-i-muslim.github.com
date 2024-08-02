import std/[jsffi, dom]
import std/[macros]

import macroplus


template c*(s: string): cstring =
  cstring s

proc charAt* (t: cstring, i: int)    : cstring {.importcpp.}
proc indexOf*(a, b: cstring)         : int     {.importcpp.}
proc substr* (s: cstring, i, l: int) : cstring {.importcpp.}
func trim*   (s: cstring)            : cstring {.importcpp.}


proc removeLastChild*(el: Element) {.importjs: "@.removeChild(@.lastChild)".}

proc contains(a, b: cstring): bool = 
  -1 != a.indexof b 


template q*(sel): untyped =
  document.querySelector sel

template q*(el, sel): untyped =
  el.querySelector sel

template qa*(sel): untyped =
  document.querySelectorAll sel


proc createElement*(tag: string): Element =
  createElement document, tag

proc createElement*(tag: string,  attrs: openArray[tuple[key, val: string]]): Element =
  result = createElement tag
  for (k, v) in attrs:
    setAttr result, cstring k, cstring v

proc appendTreeImpl(root, body: NimNode, acc: var NimNode)= 
    case kind body
    of nnkStmtList: 
        for node in body:
            appendTreeImpl root, node, acc
    
    of nnkCall: 
        for node in body[CallArgs]:
            appendTreeImpl body[CallIdent], node, acc
        appendTreeImpl root, body[CallIdent], acc

    of nnkIdent: 
        add acc, quote do:
            `root`.appendChild `body`

    else: 
        doAssert false

macro appendTree*(root, body): untyped = 
    runnableExamples:
      appendTree mainEl:
        el1
        el2:
            el2_1:
                el2_1_1
        el3:
            el3_1
            el3_2
            el3_3  

    result = newStmtList()
    appendTreeImpl root, body, result
  
# -----------------------------------------------------

template iff*(cond, iftrue, iffalse): untyped =
  if cond:
    iftrue
  else:
    iffalse

# -----------------------------------------------------

const 
  persianJunctionC* = c"ـ"
  emptyC*           = c""
  spaceC*           = c" "
  newlineC*         = c "\n"


func isPersianChar*(ch: cstring): bool = 
  ch in c"آإابپتثجچحخدذرزژسشصضطظعغفقکگلمنوهی"

func isContinousPersianChar*(ch: cstring): bool = 
  ch in c"بتثحخجچصضقفغعهکلیسئمن"
