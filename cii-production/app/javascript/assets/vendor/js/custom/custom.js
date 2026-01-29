$(document).on('turbolinks:load', function () {
  let toggler = document.querySelectorAll('.form-password-toggle i');  

  if (typeof toggler !== 'undefined' && toggler !== null) {
    toggler.forEach(function (el) {
      el.addEventListener('click', function (e) {
        e.preventDefault();

        let formPasswordToggle = el.closest('.form-password-toggle');
        let formPasswordToggleIcon = formPasswordToggle.querySelector('i');
        let formPasswordToggleInput = formPasswordToggle.querySelector('input');

        if (formPasswordToggleInput.getAttribute('type') === 'text') {
          formPasswordToggleInput.setAttribute('type', 'password');
          formPasswordToggleIcon.classList.replace('bx-show', 'bx-hide');
        } else if (formPasswordToggleInput.getAttribute('type') === 'password') {
          formPasswordToggleInput.setAttribute('type', 'text');
          formPasswordToggleIcon.classList.replace('bx-hide', 'bx-show');
        }
      });
    });
  }

  $(".number-input").keydown(function (event) {
    let charCode = event.keyCode;

    if (((charCode > 31 && (charCode < 48 || charCode > 57) && (charCode < 96 || charCode > 105)) && charCode !== 46)) {
      event.preventDefault();
    }
  });

  $('.company-logo').change(function () {
    let file = this.files[0];

    if (file) {
      let reader = new FileReader();

      reader.onload = function (event) {
        $('#imgPreview').attr('src', event.target.result);
        $('#imgPreview').attr('alt', file.name);
        $('#imgPreview').attr('title', file.name);
        $(".image-remove").remove();
        $('#imgPreview').before('<button type="button" class="btn-close image-remove" aria-label="Close"></button>');
        $(".image-remove").click(function (e) {
          e.preventDefault();
          $('#imgPreview').attr('src', '/assets/no-image.png');
          $('.company-logo').val("");
          $(this).remove();
        });
      }

      reader.readAsDataURL(file);
    } else {
      $(".image-remove").click();
    }
  });


});


