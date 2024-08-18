import std/[strutils, tables, random, tables, sequtils]
import std/[jsconsole, jsffi, dom]

import parsetoml

import ./[types, page, utils]

# -------------------------------------

var ctx: StoryCtx

# -------------------------------------

template parserKeyErr(msg): untyped =
  raise newException(KeyError, msg)
  

func parseCharacter(t: TomlValueRef): Character = 
  for prop, value in t.getTable:
    case prop
    of "pfp", "image":
      result.pfp = value.getStr
    else:
      parserKeyErr "invalid key under character: " & prop 

func parseOptionItem(t: TomlValueRef): OptionItem = 
  for prop, value in t.getTable:
    case prop
    of "next": 
      result.next = value.getStr
    of "text": 
      result.text = value.getStr
    else:
      parserKeyErr "invalid key under option-item: " & prop
  
func parseScene(t: TomlValueRef): Scene = 
  if   "text"  in t: 
    result.msg = Message(kind: mkContent, content: Content(kind: ckText))
  elif "image" in t: 
    result.msg = Message(kind: mkContent, content: Content(kind: ckImage))
  elif "options" in t: 
    result.msg = Message(kind: mkOptions, options: @[])
  else:
    parserKeyErr "invalid scene content type"
    
  
  for prop, value in t.getTable:
    case prop
    of "who":
      result.character = value.getStr
    of "next":
      result.msg.next = value.getStr
    
    of "text":
      result.msg.content.text = value.getStr
    
    of "image": 
      result.msg.content.imageUrl = value.getStr
    of "width":
      result.msg.content.maxWidth = value.getInt
    of "pixel-art": 
      result.msg.content.style = isPixelArt
    
    of "options":
      for op in value.getElems:
        result.msg.options.add parseOptionItem op

    else:
      parserKeyErr "invalid key under scene: " & prop 


proc parseStory(t: TomlValueRef): Story = 
  result = Story()

  for k, val in t.tableVal:
    case k
    of "title":
      result.title = getStr val
    
    of "characters":
      for id, ch in val.getTable:
        result.characters[id] = parseCharacter ch

    of "scenes":
      for id, sc in val.getTable:
        result.scenes[id] = parseScene sc
    
    else:
      parserKeyErr "invalid key under story toml data: " & k

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
    span    = createElement("span", {"class": "text-wrapper text-break text-secondary"})
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

proc tell(ctx: StoryCtx, container: Element) = 
  if ctx.key != "done":
    let 
      scene = ctx.story.scenes[ctx.key]
      chara = ctx.story.characters[scene.character]
      msg   = scene.msg

    ctx.history.add ctx.key

    case msg.kind
    of mkContent:

      case msg.content.kind
      of ckText:
        var e = Env()
        let contentEl = textContentHtml(ctx.key, chara.pfp)
        appendChild container, contentEl
        mockKeyboardType e, q(contentEl, ".text-wrapper"), 40, cstring msg.content.text
      
      of ckImage:
        let contentEl = imgContentHtml(
          ctx.key,
          chara.pfp, 
          msg.content.imageUrl, 
          msg.content.style,
          msg.content.maxWidth,
        )
        appendChild container, contentEl
      
      ctx.key = msg.next
    
    of mkOptions:
      let contentEl = choisesHtml(ctx.key, chara.pfp, msg.options)
      appendChild container, contentEl


template currentScene: untyped =
  ctx.story.scenes[ctx.history[^1]]
  

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

proc downloadFrom(url: cstring, succeed: proc(content: cstring), failed: proc(err: JsObject)) {.importc.}

proc storyFileUrl(storyName: cstring): cstring = 
  c"/stories/"         &
  storyName            &  
  ".toml"


proc downloadStory = 
  let url = storyFileUrl window.location.search.substr(1) 
    
  proc ifSucceed(content: cstring) = 
    ctx = StoryCtx(
      story: parseStory parseToml $content,
      key: "start")

  proc ifFailed(e: JsObject) = 
    console.log e
    echo "error ..."

  downloadFrom url, ifSucceed, ifFailed

proc runStoryTeller {.exportc.} = 
  prepare()
  downloadStory()


proc onkeydownEventHandlerStoryTeller(e: Event) {.exportc.} =
  let kc = cast[KeyboardEvent](e).keycode
  case kc
  of 37: previe() # left
  of 39: nextie() # right
  else: discard
