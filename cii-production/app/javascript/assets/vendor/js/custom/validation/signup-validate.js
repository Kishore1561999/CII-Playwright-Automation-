$(document).on('load turbolinks:load', function () {

  $("#registration_form").validate({
    rules: {
      'user[company_name]': {
        required: true
      },
      'user[company_sector]': {
        required: true
      },
      'user[company_scale]': {
        required: true
      },
      'user[gst]': {
        required: true
      },
      'user[pan_no]': {
        required: true
      },
      'user[company_description]': {
        required: true
      },
      'user[company_logo]': {
        required: true,
        extension: "jpg|jpeg|png",
      },
      'user[company_address_line1]': {
        required: true
      },
      'user[company_country]': {
        required: true
      },
      'user[company_state]': {
        required: true
      },
      'user[company_city]': {
        required: true
      },
      'user[company_zip]': {
        required: true,
        number: true
      },
      'user[primary_name]': {
        required: true,
      },
      'user[primary_email]': {
        required: true,
        email: true
      },
      'user[primary_designation]': {
        required: true,
      },
      'user[primary_contact]': {
        required: true
      },
      'user[alternate_email]': {
        email: true
      },
      'user[email]': {
        required: true,
        email: true
      },
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
      'user[company_name]': "Company Name can't be blank",
      'user[company_sector]': "Company Sector can't be blank",
      'user[company_scale]': "Company Scale can't be blank",
      'user[gst]': "GST Number can't be blank",
      'user[pan_no]': "PAN Number can't be blank",
      'user[company_description]': "Company Description can't be blank",
      'user[company_logo]': {
        required: "Company Logo can't be blank",
        extension: "Invalid file format"
      },
      'user[company_address_line1]': {
        required: "Company Address Line 1 can't be blank"
      },
      'user[company_country]': "Company Country can't be blank",
      'user[company_state]': "Company State can't be blank",
      'user[company_city]': "Company City can't be blank",
      'user[company_zip]': {
        required: "Company Zip can't be blank",
        number: "Please enter only numbers"
      },
      'user[primary_name]': {
        required: "Name can't be blank"
      },
      'user[primary_email]': {
        required: "Email can't be blank",
        email: "Please enter a valid email address"
      },
      'user[primary_designation]': {
        required: "Designation can't be blank"
      },
      'user[primary_contact]': {
        required: "Contact can't be blank"
      },
      'user[alternate_email]': {
        email: "Please enter a valid email address"
      },
      'user[email]': {
        required: "Email can't be blank",
        email: "Please enter a valid email address"
      },
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

  $("input[name='user[subscription_services]']").change(function() {
    $('#subscription-error').remove();
  });

  $("input[type='checkbox']").change(function() {
    $('#checkbox-error').remove();
  });

  $('#next-btn').click(function (e) {
    e.preventDefault();

    let valid = $("#registration_form").valid();
    
    if ($("#payment-info").hasClass("active")) { 
      if ($('#services').is(':checked')) {
        if (!$("input[name='user[subscription_services]']:checked").val()) {
          $('#subscription-error').remove();
          $('<div id="subscription-error" class="text-danger subscription-error-align">Please select a subscription service</div>').insertAfter('#subscrition_options_validate');
          e.preventDefault();
          return;
        }
      }
      if (!$(".validate-checkbox").is(':checked')) {
        $('#checkbox-error').remove();
        $('<div id="checkbox-error" class="text-danger services-error-align">Please select at least one service</div>').insertAfter('#payment-checkbox-validation');
        e.preventDefault();
        return;
      }
    } 
    if (valid) {
      $('.nav-pills .active').parent().next('li').find('button').trigger('click');
    }
  });

  let typingTimer;  // Timer identifier
  const doneTypingInterval = 1000;  // Time in milliseconds (1 second)

  $('#user_email').on('keyup', function () {
    clearTimeout(typingTimer);  // Clear the timer on keyup
    typingTimer = setTimeout(doneTyping, doneTypingInterval);  // Start a new timer
  });

  $('#user_email').on('keydown', function () {
    clearTimeout(typingTimer);  // Clear the timer on keydown to reset it
  });
  var responsearray = [];
  function doneTyping() {
    const email = $('#user_email').val();
     responsearray = [];
    $.ajax({
      url: '/email_validation/check',
      method: 'GET',
      data: { email: email },
      success: function (response) {
        responsearray.push(response.status);
      },
      error: function (error) {
        console.error('Error occurred:', error);
      }
    });
  }
   
  $('.register-button').click(function (e) {
   
    let valid = $("#registration_form").valid();

    if ($('#services').is(':checked')) {
      if (!$("input[name='user[subscription_services]']:checked").val()) {
        $('#subscription-error').remove();
        $('<div id="subscription-error" class="text-danger subscription-error-align">Please select a subscription service</div>').insertAfter('#subscrition_options_validate');
        e.preventDefault();
        return;
      }
    }
    if ($("#payment-info").hasClass("active")) { 
      if (!$(".validate-checkbox").is(':checked')) {
        $('#checkbox-error').remove();
        $('<div id="checkbox-error" class="text-danger services-error-align">Please select at least one service</div>').insertAfter('#payment-checkbox-validation');
        e.preventDefault();
        return;
      }
    } 
    const requiredFields = [
      '#user_company_name',
      '#user_company_sector',
      '#user_company_scale',
      '#user_company_description',
      '#user_gst',
      '#user_company_logo',
      '#user_company_address_line1',
      '#user_company_country',
      '#user_company_state',
      '#user_company_city',
      '#user_company_zip',
      '#user_pan_no',
      '#user_primary_name',
      '#user_primary_email',
      '#user_primary_designation',
      '#user_primary_contact',
      '#user_email',
      '#user_password',
      '#user_password_confirmation'
    ];
    if (valid) {
      $('.nav-pills .active').parent().next('li').find('button').trigger('click');
      const allFieldsFilled = requiredFields.every(function(selector) {
        return $(selector).val().trim() !== '';
      });
        console.log(responsearray)
        if (allFieldsFilled && $('#services').is(':checked') && !responsearray.includes(200)) {
          window.open('https://cam.mycii.in/ORNew/Registration.html?EventId=E000066554', '_blank');
        }
      
    }
  });
});
