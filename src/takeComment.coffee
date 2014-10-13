socket = io.connect( 'http://127.0.0.1:3000/')


theWindow = $(window)
inputArea = $('.inputMessage')


#Omit connection check temporarily.
sendMessage = ()->
	comment = inputArea.val()

	if comment
		inputArea.val('')
		socket.emit 'comment', comment


$(() ->
    options = {
            width: 14,
            chars_preset: 'alpha',
    }

    stationBar = $('#station').flapper(options);

    all_word = {
            0: '我要上弹幕>.<   ',
            1: '欢迎甩节操。    ',
            2: '不许说脏话-_-   ',
            3: '不许聊天。。    ',
            4: '来玩Ingress=o= ',
            5: '请选绿军。     '
    }

    setTimeout(()->
            toggle = 0
    
            setInterval(()->
                        stationBar.val(all_word[toggle]).change()
                        ++toggle

                        toggle %= 5
                    ,
                    10000
                    )
        ,
        500
    )

    $('#send').click(()->
        sendMessage()
    )
)



