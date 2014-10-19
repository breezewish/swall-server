theWindow = $(window)
theInput = document.getElementById('msg')
classmsg = $('.msg')
color = ''


encodeForm = ()->
    allInformation = []
    theInput = document.getElementById('msg')

    allInformation.push("msg" + "=" + theInput.value)
    allInformation.push("color" + "=" + color)

    return allInformation.join("&")


sendComment  = ()->
    request  = new XMLHttpRequest()
    request.timeout = 3000

    request.onreadystatechange = ()->
            if (request.readyState == 4 && request.status == 200)
                $('.submit').html('Submit')

    request.open("POST", "/1", true)
    request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    request.send(encodeForm())


$(() ->
    options = {
        width: 14,
        chars_preset: 'alpha',
    }

    classmsg.keypress (e)->
        $('.submit').click() if e.which is 13

    $('.submit').click ()->
        classmsg.focus()
        color = $(this).attr('datacolor')

        newfog = $('<div>').css({top: $(this).position().top, left: $(this).position().left, position:'absolute', width: $(this).width(), height: $(this).height(), 'z-index': 10}).appendTo($('#textbox'))
        newfog.offset($(this).offset())
        newfog.addClass('fogstart')

        newfog.addClass('fogend')

        window.setTimeout ()->
            newfog.remove()
        ,
        1000

        if theInput.value.length > 0
            newText = $('<div>').addClass('moveit')
                .appendTo $('#textbox')
                .css
                    top: classmsg.position().top
                    left: classmsg.position().left
                    position: 'absolute'
                    width: classmsg.width()
                    height: classmsg.height()
                    padding: '0 20px'
                    'font-size': '1.5em'
                    'line-height': "#{classmsg.height()}px"
                    border: '1px solid transparent'

            newText.text(theInput.value)
            setTimeout -> 
                newText.addClass('moveit-end')
            , 0

            window.setTimeout ()->
                newText.remove()
            , 2000

            sendComment()
            theInput.value = ''

            $('.submit').html('Send...')

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



