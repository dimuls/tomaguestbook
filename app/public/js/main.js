jQuery.fn.center = function () {
  var viewportWidth = jQuery(window).width(),
    viewportHeight = jQuery(window).height(),
    $foo = jQuery(this),
    elWidth = $foo.width(),
    elHeight = $foo.height(),
    elOffset = $foo.offset();
  jQuery(window)
    .scrollTop(elOffset.top + (elHeight/2) - (viewportHeight/2))
    .scrollLeft(elOffset.left + (elWidth/2) - (viewportWidth/2));
}

function isWriteMsgActive() {
  $('.row.write-msg-form').hasClass('hidden');
};

function updateCaptcha() {
  $.get('/captcha/update', function(captcha) {
    $('.row.write-msg-form img.captcha').attr('src', captcha);
  });
}

function postMessage() {
  $.post('/message', {
    name: $('#writer-name').val(),
    message: $('#writer-message').val(),
    captcha: $('#writer-captcha').val(),
  }, function(res) {
    if( res.error !== undefined ) {
      updateCaptcha();
      $('#writer-error').text(res.error);
    } else {
      window.location.replace('/');
    }
  });
  return false;
}

$(document).ready(function() { 
  $('.row.write-msg-btn button').click(function() {
    $.get('/captcha', function(captcha) {
      $('.row.write-msg-form img.captcha').attr('src', captcha);
    }).success(function() {
      $('.row.write-msg-btn button').hide();
      $('.row.write-msg-form').removeClass('hidden');
      $('form.write-message').center();
    });
  });
  
  $('form.write-message button.send').click(postMessage);

  $('form.write-message button.cancel').click(function() {
    if( !isWriteMsgActive() ) {
      $('.row.write-msg-btn button').show();
      $('.row.write-msg-form').addClass('hidden');
      $('img.toma-photo').center();
    }
    return false;
  });
  $('.row.write-msg-form img.captcha').click(updateCaptcha);
  $('.row.write-msg-form img.captcha').error(updateCaptcha);
});
