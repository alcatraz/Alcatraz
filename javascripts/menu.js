$(document).ready(function() {
  var components = window.location.toString().split("/");
  if (components.length > 4) {
    $("#"+components[3]).addClass("active");
  } else {
    $("#index").addClass("active");
  }
});
