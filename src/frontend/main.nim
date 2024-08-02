import std/[strutils, tables, random]
import std/[jsconsole, dom]

import ./[types, page, utils]

# -------------------------------------

proc prepare =
  randomize()


func msgId(sceneId: string): string = 
  "scene-" & sceneId

proc textContentHtml(sceneid: string, pfp: Url): Element = 
  let 
    tr      = createElement("tr",   {"id": msgId sceneid })
    td1     = createElement("td",   {"class": "align-middle", "dir": "auto"})
    span    = createElement("span", {"class": "text-wrapper text-break"})
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


var ctx: StoryCtx


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

# func toNarrative(s: string): Narrative = 
#   discard

when isMainModule:
  prepare()

  let story = Story(
    starter: "start",
    characters: toTable {
      "brain": Character(
        name: "brain",
        pfp:  "brain.png"
      ),
      "you": Character(
        name: "you",
        pfp:  "ave.png",
      ),
      "no one": Character(
        name: "no one",
        pfp:  "nothing.png",
      ),
      "prophet": Character(
        name: "prophet",
        pfp:  "prophet.png",
      ),
    },
    narrative: toTable {
      "start": Scene(
        id:        "selfie", 
        character: "you",
        msg:        Message(
          kind: mkContent,
          next: "selfie",
          content: Content(
            kind: ckText,
            text: strip """
              پوففففف بالاخره بعد از کلی درس و چیزای الکی اومدم بیرون یکم هوا بخورم              
            """,
          )
        )
      ),
      "selfie": Scene(
        id:        "start", 
        character: "no one",
        msg:        Message(
          kind: mkContent,
          next: "good-weather",
          content: Content(
            kind: ckImage,
            style: isPixelArt,
            maxWidth: 600,
            imageUrl: "self.png",
          ),
        )
      ),
      "good-weather": Scene(
        id:        "good-weather", 
        character: "you",
        msg:        Message(
          kind: mkContent,
          next: "3rd-view",
          content: Content(
            kind: ckText,
            text: strip """
              واقعا هوای خوبیه امروز
            """
          )
        )
      ),
      "3rd-view": Scene(
        id:        "3rd-view", 
        character: "no one",
        msg:        Message(
          kind: mkContent,
          next: "saw-other-one",
          content: Content(
            kind: ckImage,
            style: isPixelArt,
            maxWidth: 800,
            imageUrl: "park.png",
          )
        )
      ),
      "saw-other-one": Scene(
        id:        "saw-other-one", 
        character: "you",
        msg:        Message(
          kind: mkContent,
          next: "what-to-do",
          content: Content(
            kind: ckText,
            text: strip """
              عه این پسره!
              این بشر همکلاسی منه.
              حالا چیکار کنم؟
            """
          )
        )
      ),
      "what-to-do": Scene(
        id:        "what-to-do", 
        character: "brain",
        msg:        Message(
          kind: mkOptions,
          options: @[
            OptionItem(
              text:"ولش کن، سرت رو بنداز پایین و رد شو",
              next:"hadith",
            ),
            OptionItem(
              text:"بزار ببینم انقد ادب داره که سلام کنه؟",
              next:"hadith",
            ),
            OptionItem(
              text:"سلام کن",
              next:"hadith",
            ),
          ]
        )
      ),
      "hadith": Scene(
        id:        "hadith", 
        character: "prophet",
        msg:        Message(
          kind: mkContent,
          next: "done",
          content: Content(
            kind: ckImage,
            style: isPixelArt,
            maxWidth: 800,
            imageUrl: "salam-hadis.jpg",
          )
        )
      ),
    },
  )

  ctx = StoryCtx(
    story: story,
    key: story.starter)


  window.addEventListener "keydown", proc (e: Event) = 
    let kc = cast[KeyboardEvent](e).keycode
    case kc
    of 37: previe() # left
    of 39: nextie() # right
    else: discard