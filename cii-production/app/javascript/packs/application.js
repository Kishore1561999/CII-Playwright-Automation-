// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require toastr/build/toastr.min

window.toastr = require("toastr")

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "../stylesheets/application"

import "../assets/vendor/js/helpers"
import "../assets/js/config"

import "../assets/vendor/libs/jquery/jquery"
import "../assets/vendor/libs/popper/popper"
import "../assets/vendor/js/bootstrap"
import "../assets/vendor/libs/perfect-scrollbar/perfect-scrollbar"
import "../assets/vendor/js/menu"

import "../assets/js/main"

import "../assets/vendor/js/custom/custom"
import "../assets/vendor/js/libs/chart"

// import "../assets/vendor/js/custom/validation/libs/jquery.validate"
// import "../assets/vendor/js/custom/validation/libs/additional-methods"
import "../assets/vendor/js/custom/validation/signup-validate"
import "../assets/vendor/js/custom/validation/user-validate"
import "../assets/vendor/js/custom/validation/change-password-validate"
//import "../assets/vendor/js/custom/validation/xmlfileupload-validate"
import "../assets/vendor/js/custom/validation/data-collection-validate"
import "../assets/vendor/js/custom/analytics-charts/analytic-chart"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
