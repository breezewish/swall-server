(function() {
  var encodeForm, sendComment, theWindow;

  theWindow = $(window);

  encodeForm = function() {
    var allInformation, theInput;
    allInformation = [];
    theInput = document.getElementById('msg');
    allInformation.push("msg" + "=" + theInput.value);
    return allInformation.join("&");
  };

  sendComment = function() {
    var request, theInput;
    theInput = document.getElementById('msg');
    request = new XMLHttpRequest();
    request.onreadystatechange = function() {
      if (request.readyState === 4 && request.status === 200) {
        theInput.value = '';
        return $('#submit').html('Submit');
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
    $('.msg').focus(function() {
      return $(this).addClass('msgbink');
    });
    $('#submit').click(function() {
      $('#submit').html('Send...');
      return sendComment();
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
