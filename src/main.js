import launchview from './launchview.svelte'
import 'jquery/dist/jquery.js'
import 'bootstrap/dist/js/bootstrap.bundle.js'
import 'bootstrap/dist/css/bootstrap.css'

var app
document.addEventListener("DOMContentLoaded", function() { 
    app = new launchview({
        target: document.body,	
    })
})

export default app