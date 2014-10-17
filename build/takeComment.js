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
    allInformation.push("msg" + "=" + theInput.value);
    allInformation.push("color" + "=" + color);
    console.log(color);
    return allInformation.join("&");
  };

  sendComment = function() {
    var request;
    request = new XMLHttpRequest();
    request.timeout = 3000;
    request.onreadystatechange = function() {
      if (request.readyState === 4 && request.status === 200) {
        return $('.submit').html('Submit');
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
      }).appendTo($('#textbox'));
      newfog.offset($(this).offset());
      newfog.addClass('fogstart');
      newfog.addClass('fogend');
      window.setTimeout(function() {
        return newfog.remove();
      }, 1000);
      if (theInput.value.length > 0) {
        newText = $('<div>').appendTo($('#textbox')).css({
          top: classmsg.position().top,
          left: classmsg.position().left,
          position: 'absolute',
          width: classmsg.width(),
          height: classmsg.height()
        });
        newText.text(theInput.value);
        newText.addClass('moveit');
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
