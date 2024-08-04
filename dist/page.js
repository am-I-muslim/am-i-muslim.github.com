function randInt(min, max) {
  return Math.floor(Math.random() * (max - min) + min)
}

function toPersianNumber(string) {
  return {
    "0": "۰",
    "1": "۱",
    "2": "۲",
    "3": "۳",
    "4": "۴",
    "5": "۵",
    "6": "۶",
    "7": "۷",
    "8": "۸",
    "9": "۹",
  }[string]
}

function downloadFrom(url, succeed, failed) {
  return fetch(url)
    .then(r => r.text())
    .then(succeed)
    .catch(failed)
}


// ------------------------------------

up.macro('[smooth-link]', link => {
  // if (!link.hasAttribute('up-transition'))
  // link.setAttribute('up-transition', 'cross-fade')
  link.setAttribute('up-transition', 'move-to-bottom/fade-in')
  link.setAttribute('up-duration', '400')
  link.setAttribute('up-follow', '')
})

up.macro('[choose-random-child]', element => {
  let i = randInt(0, element.childElementCount)
  let chosen = element.children[i]
  element.replaceChildren(chosen)
})

up.compiler('[fa-digits]', element => {
  element.innerHTML = element.innerHTML.replace(/\d/gmi, toPersianNumber)
})

up.compiler('#story-table-container', element => {
  // https://github.com/nim-lang/Nim/issues/23921
  const
    attachStoryTeller = () => window.addEventListener("keydown", onkeydownEventHandlerStoryTeller),
    deattachStoryTeller = () => window.removeEventListener("keydown", onkeydownEventHandlerStoryTeller)

  attachStoryTeller()
  runStoryTeller()
  return deattachStoryTeller
})
