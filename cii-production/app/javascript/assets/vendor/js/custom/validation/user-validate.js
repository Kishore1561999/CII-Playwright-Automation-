$(document).on('turbolinks:load', function () {
  $("#user-form").validate({
    rules: {
      'user[password]': {
        required: true,
        pwcheck: true
      },
      'user[password_confirmation]': {
        required: true,
        equalTo: "#user_password"
      }
    },
    messages: {
      'user[password]': {
        required: "Password can't be blank",
        pwcheck: "Password must contain  at least 8 characters that includes at least 1 lowercase , 1 uppercase, 1 number, and 1 special character in !@#$%^&*"
      },
      'user[password_confirmation]': {
        required: "Confirm Password can't be blank",
        equalTo: "Password and Confirm Password must be same"
      }
    },
    errorPlacement: function (error, element) {
      if (element.attr("id") == "user_password") {
        error.insertAfter("#password_field");
      } else if (element.attr("id") == "user_password_confirmation") {
        error.insertAfter("#confirm_password_field");
      } else {
        error.insertAfter(element);
      }
    }
  });

  $.validator.addMethod("pwcheck", function (value) {
    return /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z0-9\d=!\-@._*#$%^&]{8,}$/.test(value);
  });

});
