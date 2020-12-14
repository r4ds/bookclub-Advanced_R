
(function() {
let tries = 0
function addLogo() {
  if (typeof slideshow === 'undefined') {
    ++tries < 10 ? setTimeout(addLogo, 100) : null
    return
  } else {
  	document.querySelectorAll('.remark-slide-content:not(.title-slide):not(.inverse):not(.hide_logo)')
    	.forEach(el => el.innerHTML += '<div class="xaringan-extra-logo"></div>')
  }
}
document.addEventListener('DOMContentLoaded', addLogo)
})()
