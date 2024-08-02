
up.macro('[smooth-link]', link => {
  // if (!link.hasAttribute('up-transition'))
  // link.setAttribute('up-transition', 'cross-fade')
  link.setAttribute('up-transition', 'move-to-bottom/fade-in')
  link.setAttribute('up-duration', '400')
  link.setAttribute('up-follow', '')
})
