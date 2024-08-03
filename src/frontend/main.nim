import std/[strutils, tables, random]
import std/[jsconsole, jsffi, dom]

import parsetoml

import ./[types, page, utils]

# -------------------------------------

var ctx: StoryCtx

# -------------------------------------

proc parseStory(t: TomlValueRef): Story = 
  console.log t

proc parseToml(s: string): TomlValueRef = 
  parsetoml.parseString s

# -------------------------------------

proc prepare =
  randomize()


func msgId(sceneId: string): string = 
  "scene-" & sceneId

proc textContentHtml(sceneid: string, pfp: Url): Element = 
  let 
    tr      = createElement("tr",   {"id": msgId sceneid })
    td1     = createElement("td",   {"class": "align-middle", "dir": "auto"})
    span    = createElement("span", {"class": "text-wrapper text-break text-primary"})
    td2     = createElement("td",   {"class": "avatar-cell"})
    avatar  = createElement("img",  {"class": "pixel-art avatar fade-in", "src": pfp})

  appendTree tr:
    td1:
      span
    td2:
      avatar
  tr

proc imgContentHtml(sceneid: string, pfp, img: Url, style: ImageStyle, maxWidth: int): Element = 
  let 
    tr      = createElement("tr",   {"id": msgId sceneid })
    td1     = createElement("td",   {"class": "align-middle text-center"})
    image   = createElement("img",  {
                                      "class": "fade-in image-content " & iff(style == isPixelArt, "pixel-art", ""), 
                                      "src": img,
                                      "style": "max-width: " & $maxWidth &  "px;",
                                    })
    td2     = createElement("td",   {"class": "avatar-cell"})
    avatar  = createElement("img",  {"class": "pixel-art avatar fade-in", "src": pfp})

  appendTree tr:
    td1:
      image
    td2:
      avatar
  tr

proc choisesHtml(sceneid: string, pfp: string, options: seq[OptionItem]): Element = 
  let 
    tr            = createElement("tr",   {"id": msgId sceneid })
    td1           = createElement("td",   {"class": "align-middle text-center"})
    choiceWrapper = createElement("ul",   {"class": "btn-group-vertical my-2"})
    td2           = createElement("td",   {"class": "avatar-cell"})
    avatar        = createElement("img",  {"class": "pixel-art avatar fade-in", "src": pfp})

  for i, o in options:
    let li = createElement("li", {"class": "btn btn-outline-primary", "onclick": "choose_option( " & $i & " )"})
    li.innerText = cstring o.text
    appendChild choiceWrapper, li

  appendTree tr:
    td1:
      choiceWrapper
    td2:
      avatar
  tr

# -------------------------------------

const publicDir = "../public/"

proc tell(ctx: StoryCtx, container: Element) = 
  if ctx.key != "done":
    let 
      scene = ctx.story.narrative[ctx.key]
      chara = ctx.story.characters[scene.character]
      msg   = scene.msg

    ctx.history.add ctx.key

    case msg.kind
    of mkContent:

      case msg.content.kind
      of ckText:
        var e = Env()
        let contentEl = textContentHtml(ctx.key, publicDir & chara.pfp)
        appendChild container, contentEl
        mockKeyboardType e, q(contentEl, ".text-wrapper"), 40, cstring msg.content.text
      
      of ckImage:
        let contentEl = imgContentHtml(
          ctx.key,
          publicDir & chara.pfp, 
          publicDir & msg.content.imageUrl, 
          msg.content.style,
          msg.content.maxWidth,
        )
        appendChild container, contentEl
      
      ctx.key = msg.next
    
    of mkOptions:
      let contentEl = choisesHtml(ctx.key, publicDir & chara.pfp, msg.options)
      appendChild container, contentEl


template currentScene: untyped =
  ctx.story.narrative[ctx.history[^1]]
  

proc canGoNext: bool = 
  0 == ctx.history.len or 
  currentScene.msg.kind != mkOptions

proc canGoPrev: bool = 
  0 < ctx.history.len


proc nextie {.exportc.} = 
  if canGoNext():
    tell ctx, q"#story-table-container"

proc previe {.exportc.} = 
  if canGoPrev():
    ctx.key = pop ctx.history
    removeLastChild q"#story-table-container"

proc choose_option(optionIndex: int) {.exportc.} = 
  ctx.key = currentScene.msg.options[optionIndex].next
  tell ctx, q"#story-table-container"

# -------------------------------------

proc downloadFrom(url: cstring, succeed: proc(content: cstring), failed: proc()) {.importc.}

proc storyFileUrl(storyName: cstring): cstring = 
  c"//"                & 
  window.location.host & 
  c"/stories/"         &
  storyName            &  
  ".toml"


proc downloadStory = 
  let url = storyFileUrl window.location.search.substr(1) 
    
  proc ifSucceed(content: cstring) = 
    ctx = StoryCtx(
      story: parseStory parseToml content,
      key: "start")

  proc ifFailed = 
    echo "cannot download story ..."

  downloadFrom url, ifSucceed, ifFailed

proc runApp {.exportc.} = 
  prepare()
  downloadStory()


proc onkeydownEventHandler(e: Event) = 
  let kc = cast[KeyboardEvent](e).keycode
  case kc
  of 37: previe() # left
  of 39: nextie() # right
  else: discard

proc appAttach {.exportc.} = 
  window.addEventListener    "keydown", onkeydownEventHandler

proc appDetach {.exportc.} = 
  window.removeEventListener "keydown", onkeydownEventHandler



when isMainModule:
  runApp()
