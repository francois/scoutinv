$(document).foundation()

// Failed or missing logos keep the group initial instead of a broken-image icon.
document.addEventListener("load", function(event) {
  if (event.target.matches && event.target.matches(".forest-group-logo")) {
    event.target.hidden = false;
  }
}, true);
document.addEventListener("error", function(event) {
  if (event.target.matches && event.target.matches(".forest-group-logo")) {
    event.target.hidden = true;
  }
}, true);

$(document).on("turbolinks:load", function(){
  document.querySelectorAll(".forest-group-logo").forEach(function(image) {
    image.hidden = !(image.complete && image.naturalWidth > 0);
  });
  document.body.addEventListener("ajax:beforeSend", function(event){
    var url = event.detail[1].url
    var id = url.replace(/\//g, "-").replace(/^-products-/, "product-").replace(/images-/, "image-").replace(/-(left|right)$/, "");
    $("#" + id + " form").remove();
    $("#" + id).addClass("connecting");
  });
});
