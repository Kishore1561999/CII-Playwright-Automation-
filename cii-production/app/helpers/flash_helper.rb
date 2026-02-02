module FlashHelper
  def toastr_flash
    flash.each_with_object([]) do |(type, message), flash_messages|
      type = type.to_s.gsub('alert', 'error').gsub('notice', 'info')
      text = "<script>toastr.#{type}('#{message}', '', {
        closeButton: true,
        positionClass: 'toast-top-right',
        onclick: null,
        showDuration: 300,
        hideDuration: 1000,
        timeOut: 5000,
        extendedTimeOut: 1000,
        showEasing: 'swing',
        hideEasing: 'linear',
        showMethod: 'fadeIn',
        progressBar: true,
        hideMethod: 'fadeOut'
      })</script>"
      flash_messages << text.html_safe if message
    end.join("\n").html_safe
  end
end
