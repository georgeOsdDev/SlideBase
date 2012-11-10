###
slideBaseClient-plugin-gaya.js
------------------------------------------------
author:  [Takeharu Oshida](http://about.me/takeharu.oshida)
version: 0.1
licence: [MIT](http://opensource.org/licenses/mit-license.php)
###

sbClient.plugins.gaya = new sbClient.Model.Plugin
  name: "gaya"
  element: """
    <div id='#gaya' class='pluginOption'>
      <span>Comment</span><br>
      <input type='text' name='gaya'></input>
      <input class='btn' name='submitGaya' type='button' value='gaya'/><br>
      <label class='radio'>
        <input type="radio" name='gayaStyle' id='gayaStyle1' value='niconico' checked> niconico
      </label>
      <label class='radio'>
        <input type='radio' name='gayaStyle' id='gayaStyle2' value='growl'> growl
      </label>
    </div>
  """
  initialScript: ->
    console.log "gaya plugin is ready"
    sbClient.gayaList = {}
    self = @
    $('[name="submitGaya"]').click ->
      gaya = $('[name="gaya"]').val()
      if gaya.length < 1 then return
      sbClient.execEmit 'gaya',gaya
      func = sbClient.plugins['gaya'].get 'callback'
      func(gaya)
      return false

  callback: (gaya)->
    console.log "gaya plugin was called: #{gaya}"
    style = $('[name="gayaStyle"]:checked').val()
    hex = '0123456789ABCDEF'.split('')

    color = ->
      ret = [
        '#'
        hex[Math.floor(Math.random() * hex.length)]
        hex[Math.floor(Math.random() * hex.length)]
        hex[Math.floor(Math.random() * hex.length)]
        hex[Math.floor(Math.random() * hex.length)]
        hex[Math.floor(Math.random() * hex.length)]
        hex[Math.floor(Math.random() * hex.length)]
      ]
      ret.join('')

    console.log color()
    css = {}
    if style is "niconico"
      css =
        'color': color()
        'left': $(window).width()
        'top': Math.floor(Math.random() * $(window).height() * 0.9)
        'position':'absolute'
        'width':'100%'
    if style is "growl"
      css =
        'color': 'white'
        'right': (Math.floor(Math.random() * 40) + 40)
        'top': ($(window).height()-(Math.floor(Math.random() * 50) + 50))
        'position':'absolute'
        'text-align': 'right'
        'background-color': '#333'
        'opacity': 0.8
        'border-radius': '3px'

    div = document.createElement "div"
    $(div).text(gaya)
      .css(css)
      .addClass('gayaMsg')

    niconicoView = ->
      timeoutCallback = ->
        $(div).remove()
      setTimeout timeoutCallback, 7000

      intervalCallback = ->
        offset = $(div).offset()
        offset.left -= 20
        $(div).offset(offset)
      setInterval intervalCallback, 75

    growlView = ->
      timeoutCallback = ->
        $(div).remove()
      setTimeout timeoutCallback, 3000

    $('body').append div
    switch style
      when "niconico"
        niconicoView()
      when "growl"
        growlView()
      else
        return

    saveGaya = (gaya)->
      # gayaList = sbClient.Collection.Slides.get "gayaList"
      # if _.isEmpty gayaList
      #   gayaList = document.createElement "section"
      #   gayaList.id = "gayaList"
      #   $("body").append gayaList
      #   model = new sbClient.Model.Slide
      #     elements:""
      #     page:sbClient.page.last + 1
      #   sbClient.Collection.Slides.add model

      l0Pad = (num) ->
        if num < 10 then "0" + num else num

      date = new Date()
      now = [
        date.getFullYear(), "-", l0Pad(date.getMonth() + 1), "-", l0Pad(date.getDate())
        " ",
        l0Pad(date.getHours()), ":", l0Pad(date.getMinutes()), ":", l0Pad(date.getSeconds())
      ].join("")
      # $(gayaList).append "<p>#{now} #{gaya.Message}</p>"
      sbClient.gayaList.now = gaya

    saveGaya()
