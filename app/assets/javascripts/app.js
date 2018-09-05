$(document).foundation()
$(document).on("turbolinks:load", function(){
  document.body.addEventListener("ajax:beforeSend", function(event){
    var url = event.detail[1].url
    var id = url.replace(/\//g, "-").replace(/^-products-/, "product-").replace(/images-/, "image-").replace(/-(left|right)$/, "");
    $("#" + id + " form").remove();
    $("#" + id).addClass("connecting");
  });
});
