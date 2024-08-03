
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

up.compiler('[fa-digits]', element => {
  element.innerHTML = element.innerHTML.replace(/\d/gmi, toPersianNumber)
})
