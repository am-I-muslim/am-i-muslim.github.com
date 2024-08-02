import std/[tables]
import std/[dom]


type # ----- aliases 

  Slug*    = string # XXX distinct string
  Emoji*   = string # XXX distinct string
  Url*     = string # XXX distinct string
  Index*   = Natural
  SceneId* = Slug

type # ----- enums

  Actionkind*  = enum
    akStateMutation
    # ak
  
  MessageKind* = enum
    mkContent
    mkOptions
  
  ContentKind* = enum
    ckText
    ckImage

  ImageStyle* = enum
    isNormal
    isPixelArt

type # ----- structures

  Content* = object
    case kind*: ContentKind

    of ckText: 
      text*: string

    of ckImage: 
      style*:    ImageStyle
      maxWidth*: Natural
      imageUrl*: Url

  # Action*  = object
  #   case kind*: Actionkind
  #   of akStateMutation:
  #     key*:   string
  #     value*: string

  Options* = seq[OptionItem]

  Message* = object
    case kind*:    MessageKind
    of mkContent: 
      content*: Content
      next*: SceneId

    of mkOptions: 
      options*: Options

  OptionItem* = object
    # emoji*:    Emoji
    # actions*:  seq[Action]
    text*:     string
    next*:     SceneId

  Scene*       = ref object
    id*:        SceneId
    character*: string
    msg*:       Message

  Character*  = ref object
    pfp*:  Url
    name*: string

  Narrative*  = Table[SceneId, Scene]

  Story*      = object
    starter*:    SceneId
    characters*: Table[string, Character] # character name => profile picture
    narrative*:  Narrative

  StoryCtx* = ref object
    story*:   Story
    key*:     SceneId
    history*: seq[SceneId]
    # choices*: seq[Index]
    # states*:  Table[string, string]
