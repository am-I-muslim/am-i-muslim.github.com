import std/[json, os, httpclient, strformat, strutils]

type
  EmojiRef = object
    slug: string
    src: string


when isMainModule:
  var secs: seq[EmojiRef]
  var c = newHttpClient()
  let j = parseFile "./emojis.json"

  for part in j:
    for data in part["images"]:
      secs.add EmojiRef(
        slug: data["slug"]           .getStr,
        src:  data["image"]["source"].getStr)

  discard existsOrCreateDir "./temp"

  for i, s in secs:
    if "tone" notin s.slug:
      let name = "temp" / s.slug & ".png"
      if not fileExists name:
        echo fmt"[{i}/{secs.len}] ", s.slug
        c.downloadFile "https://em-content.zobj.net/" & s.src, name
