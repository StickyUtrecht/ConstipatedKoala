/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

//import "jquery/dist/jquery.min"
//import "jquery-ujs/src/rails"
import "../../../vendor/assets/javascripts/bootstrap-file-input";
import "toastr"
import "../src/lib/dropdown"
import "../src/lib/editor"
import "../src/lib/mail"
import "clipboard/dist/clipboard.min"
import "turbolinks/dist/turbolinks"
import "bootstrap/dist/js/bootstrap.bundle.min.js"
import "../src/admin/index.js"
import "../src/language.js"
import "../src/application.js"
import "jquery"

require("turbolinks").start();