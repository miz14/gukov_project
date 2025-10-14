function showText(el) {
    const p_elem = el.parentNode.children[1];
    console.log(p_elem)

    
    if (! el.classList.contains('active')) {
        p_elem.classList.add('show')
        el.classList.add('active')
    } else {
        p_elem.classList.remove('show')
        el.classList.remove('active')
    }
}