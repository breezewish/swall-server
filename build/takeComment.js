(function() {
  var inputArea, theWindow;

  theWindow = $(window);

  inputArea = $('.inputMessage');

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
