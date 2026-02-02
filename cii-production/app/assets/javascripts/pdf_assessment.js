$(function() {
    $("input[type=radio]:checked, input[type=checkbox]:checked").each(function () {
        $("." + this.name).addClass("d-none");

        if ($(this).attr('title')) {
            $("#" + this.title).removeClass("d-none");
        }
    });
});
