(function() {
  var classmsg, color, encodeForm, sendComment, theInput, theWindow;

  theWindow = $(window);

  theInput = document.getElementById('msg');

  classmsg = $('.msg');

  color = '';

  encodeForm = function() {
    var allInformation;
    allInformation = [];
    theInput = document.getElementById('msg');
    allInformation.push("msg" + "=" + encodeURIComponent(theInput.value));
    allInformation.push("color" + "=" + encodeURIComponent(color));
    allInformation.push("HTTP_X_REQUESTED_WITH" + "=" + encodeURIComponent('xmlhttprequest'));
    return allInformation.join("&");
  };

  sendComment = function() {
    var error, request;
    try {
      if (window.XMLHttpRequest) {
        request = new XMLHttpRequest();
      } else {
        request = new ActiveXObject("Microsoft.XMLHTTP");
      }
    } catch (_error) {
      error = _error;
      alert(error);
    }
    request.timeout = 3000;
    request.onreadystatechange = function() {
      if (request.readyState === 4 && request.status === 200) {
        return $('.submit').html('Ok');
      }
    };
    request.open("POST", "/1", true);
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    return request.send(encodeForm());
  };

  $(function() {
    var all_word, options, stationBar;
    options = {
      width: 14,
      chars_preset: 'alpha'
    };
    classmsg.keypress(function(e) {
      if (e.which === 13) {
        return $('.submit').click();
      }
    });
    $('.submit').click(function() {
      var newText, newfog;
      classmsg.focus();
      color = $(this).attr('datacolor');
      newfog = $('<div>').css({
        top: $(this).position().top,
        left: $(this).position().left,
        position: 'absolute',
        width: $(this).width(),
        height: $(this).height(),
        'z-index': 10
      }).appendTo($('#text-box'));
      newfog.offset($(this)).offset();
      newfog.addClass('fogstart');
      newfog.addClass('fogend');
      window.setTimeout(function() {
        return newfog.remove();
      }, 1000);
      if (theInput.value.length > 0) {
        newText = $('<div>').addClass('moveit').appendTo($('#text-box')).css({
          top: classmsg.position().top,
          left: classmsg.position().left,
          position: 'absolute',
          width: classmsg.width(),
          height: classmsg.height(),
          padding: '0 20px',
          'font-size': '1.5em',
          'line-height': "" + (classmsg.height()) + "px",
          border: '1px solid transparent'
        });
        newText.text(theInput.value);
        setTimeout(function() {
          return newText.addClass('moveit-end');
        }, 0);
        window.setTimeout(function() {
          return newText.remove();
        }, 2000);
        sendComment();
        theInput.value = '';
        return $('.submit').html('Send...');
      }
    });
    stationBar = $('#station').flapper(options);
    all_word = {
      0: '我要上弹幕>.<      ',
      1: '欢迎甩节操。        ',
      2: '不许说脏话-_-      ',
      3: '不许聊天。。        ',
      4: '来玩Ingress=o=  ',
      5: '请选绿军。         '
    };
    return setTimeout(function() {
      var toggle;
      toggle = 0;
      return setInterval(function() {
        stationBar.val(all_word[toggle]).change();
        ++toggle;
        return toggle %= 6;
      }, 10000);
    }, 500);
  });

}).call(this);
