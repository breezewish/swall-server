theWindow = $(window)
theInput = document.getElementById('msg')


encodeForm = ()->
    allInformation = []
    theInput = document.getElementById('msg')

    allInformation.push("msg" + "=" + theInput.value)

    return allInformation.join("&")


sendComment  = ()->
    request  = new XMLHttpRequest()

    request.onreadystatechange = ()->
            if (request.readyState == 4 && request.status == 200)
                theInput.value = ''
                $('#submit').html('Submit')

    request.open("POST", "/1", true)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.send(encodeForm())


$(() ->
    options = {
            width: 14,
            chars_preset: 'alpha',
    }

    $('.msg').focus(()->
        $(this).addClass('msgbink')
    )

    $('#submit').click(()->
        if theInput.value.length > 0
            sendComment()
            $('#submit').html('Send...')
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



