$(document).on('load turbolinks:load', function () {
    $("#cii_data_collection_user").validate({
      rules: {
        'company_name': {
          required: true
        },
        'company_sector': {
          required: true
        },
        'analyst_user_id': {
          required: true
        }
      },
      messages: {
        'company_name': "Company Name can't be blank",
        'company_sector': "Company Sector can't be blank",
        'analyst_user_id': "Please Select the Analyst"
      },
      errorPlacement: function (error, element) {
          error.insertAfter(element);
      }
    });
});
