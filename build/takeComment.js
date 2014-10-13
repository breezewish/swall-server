(function() {
  var inputArea, sendMessage, socket, theWindow;

  socket = io.connect('http://127.0.0.1:3000/');

  theWindow = $(window);

  inputArea = $('.inputMessage');

  sendMessage = function() {
    var comment;
    comment = inputArea.val();
    if (comment) {
      inputArea.val('');
      return socket.emit('comment', comment);
    }
  };

  $(function() {
    var all_word, options, stationBar;
    options = {
      width: 14,
      chars_preset: 'alpha'
    };
    stationBar = $('#station').flapper(options);
    all_word = {
      0: '我要上弹幕>.<   ',
      1: '欢迎甩节操。    ',
      2: '不许说脏话-_-   ',
      3: '不许聊天。。    ',
      4: '来玩Ingress=o= ',
      5: '请选绿军。     '
    };
    setTimeout(function() {
      var toggle;
      toggle = 0;
      return setInterval(function() {
        stationBar.val(all_word[toggle]).change();
        ++toggle;
        return toggle %= 5;
      }, 10000);
    }, 500);
    return $('#send').click(function() {
      return sendMessage();
    });
  });

}).call(this);
