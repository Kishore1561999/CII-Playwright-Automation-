document.addEventListener('turbolinks:load', function () {
  var $uploadStatus = $("input[name='upload_status']");
  var $uploadSubmit = $('#upload_submit');
  var $paymentCheckboxValidation = $('#payment-checkbox-validation');

  $uploadStatus.change(function() {
      $('#checkbox-error').remove();
  });

  $uploadSubmit.click(function (e) {
      if (!$(".upload-status").is(':checked')) {
          $('#checkbox-error').remove();
          $('<div id="checkbox-error" class="text-danger services-error-align">Please select any one option</div>')
              .insertAfter($paymentCheckboxValidation);
          e.preventDefault();
      }
  });
});
