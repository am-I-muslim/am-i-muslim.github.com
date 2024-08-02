import std/[strutils, tables, random]
import std/[jsconsole, dom]

import ./[types, page, utils]

# -------------------------------------

proc prepare =
  randomize()

proc textContentHtml(pfp: Url): Element = 
  let 
    tr      = createElement("tr",   {"class": "",})
    td1     = createElement("td",   {"class": "align-middle", "dir": "auto"})
    span    = createElement("span", {"class": "text-wrapper"})
    td2     = createElement("td",   {"class": "avatar-cell"})
    avatar  = createElement("img",  {"class": "pixel-art avatar", "src": pfp})

  appendTree tr:
    td1:
      span
    td2:
      avatar
  tr

proc imgContentHtml(pfp, img: Url, style: ImageStyle, maxWidth: int): Element = 
  let 
    tr      = createElement("tr",   {"class": "",})
    td1     = createElement("td",   {"class": "align-middle text-center"})
    image   = createElement("img",  {
                                      "class": "fade-in image-content " & iff(style == isPixelArt, "pixel-art", ""), 
                                      "src": img,
                                      "style": "max-width: " & $maxWidth &  "px;",
                                    })
    td2     = createElement("td",   {"class": "avatar-cell"})
    avatar  = createElement("img",  {"class": "pixel-art avatar", "src": pfp})

  appendTree tr:
    td1:
      image
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
        let contentEl = textContentHtml(publicDir & chara.pfp)
        appendChild container, contentEl
        mockKeyboardType e, q(contentEl, ".text-wrapper"), 40, cstring msg.content.text
      
      of ckImage:
        let contentEl = imgContentHtml(
          publicDir & chara.pfp, 
          publicDir & msg.content.imageUrl, 
          msg.content.style,
          msg.content.maxWidth,
        )
        appendChild container, contentEl
      
      ctx.key = msg.next
    
    else: 
      discard


var ctx: StoryCtx

proc nextie {.exportc.} = 
  # TODO fast next click ==> skip
  tell ctx, q"#story-table-container"

proc previe {.exportc.} = 
  ctx.key = pop ctx.history
  removeLastChild q"#story-table-container"

# -------------------------------------

func toNarrative(s: string): Narrative = 
  discard """
 
  """

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
    },
    narrative: toTable {
      "start": Scene(
        id:        "start", 
        character: "brain",
        msg:        Message(
          kind: mkContent,
          next: "p1",
          content: Content(
            kind: ckText,
            text: strip """
              سلام. خوبی؟ منتظرت بودم
            """,
          )
        )
      ),
      "p1": Scene(
        id:        "p1", 
        character: "you",
        msg:        Message(
          kind: mkContent,
          next: "p2",
          content: Content(
            kind: ckText,
            text: strip """
              نه بابا! راست میگی؟ کاشت رو بیار ماست بگیر خخخخخخخخخخخخخخخخخخخخخخخخخخخخخخخ
            """,
          )
        )
      ),
      "p2": Scene(
        id:        "p2", 
        character: "brain",
        msg:        Message(
          kind: mkContent,
          next: "done",
          content: Content(
            kind: ckImage,
            style: isPixelArt,
            maxWidth: 800,
            imageUrl: "park.png",
          )
        )
      ),

    },
  )

  ctx = StoryCtx(
    story: story,
    key: story.starter)
