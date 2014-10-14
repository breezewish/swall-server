theWindow = $(window)
inputArea = $('.inputMessage')


$(() ->
    options = {
            width: 14,
            chars_preset: 'alpha',
    }

    $('.msg').focus(()->
        $(this).addClass('msgbink')
    )

    stationBar = $('#station').flapper(options);

    all_word = {
            0: '我要上弹幕>.<      ',
            1: '欢迎甩节操。        ',
            2: '不许说脏话-_-      ',
            3: '不许聊天。。        ',
            4: '来玩Ingress=o=  ',
            5: '请选绿军。         '
    }

    setTimeout(()->
            toggle = 0
    
            setInterval(()->
                        stationBar.val(all_word[toggle]).change()
                        ++toggle
                        toggle %= 6
                    ,
                    10000
                    )
        ,
        500
    )
)



