theWindow = $(window)
theInput = document.getElementById 'msg'
classmsg = $('.msg')


setButton = ()->
    $('.submit').html('Ok')


sendComment  = (postData)->
    $.ajax
        type: 'POST'
        url: window.location.pathname
        data: postData
        success: setButton
        timeout: 3000

    $(document).ajaxSuccess (event, xhr, settings)->
        if xhr.response != undefined
            alert xhr.response


$(() ->
    color   = ''
    options =
        width: 14
        chars_preset: 'alpha'

    classmsg.keypress (e)->
        $('.submit').click() if e.which is 13

    $('form').submit ()->
        return false

    $('.submit').click ()->
        return if $('.submit').attr('disabled')
        $('.submit').attr('disabled', 'disabled')
        setTimeout ->
            $('.submit').removeAttr('disabled')
        , 3000

        classmsg.focus()
        color = $(this).attr('datacolor')

        newfog = $('<div>').css
            top: $(this).position().top
            left: $(this).position().left
            position:'absolute'
            width: $(this).width()
            height: $(this).height()
            'z-index': 10
        .appendTo $('#text-box')

        newfog.offset $(this)
            .offset()

        newfog.addClass 'fogstart'

        newfog.addClass 'fogend'

        window.setTimeout ()->
            newfog.remove()
        ,
        1000

        if theInput.value.length > 0
            newText = $('<div>').addClass('moveit')
                .appendTo $('#text-box')
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
            newText.text theInput.value
            setTimeout ->
                newText.addClass 'moveit-end'
            , 0

            window.setTimeout ()->
                newText.remove()
            , 2000

            postData =
                msg: theInput.value
                color: color

            sendComment(postData)
            theInput.value = ''

            $('.submit').html 'Send...'

        return false

    stationBar = $('#station').flapper(options)

    all_word =
            0: 'English Only '
            1: 'No Four-Letter'

    setTimeout ()->
            toggle = 0

            stationBar.val(all_word[0]).change()
            ++toggle
    
            setInterval ()->
                        stationBar.val(all_word[toggle]).change()
                        ++toggle
                        toggle %= 2
                    ,
                    10000
        ,
        10
)

