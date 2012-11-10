###
SlideBaseClient.js
------------------------------------------------
author:  [Takeharu Oshida](http://about.me/takeharu.oshida)
version: 0.1
licence: [MIT](http://opensource.org/licenses/mit-license.php)
###

console.log "This is Client Side Script"

# Namespace
window.sbClient =
  admin:false
  lock:false
  page:
    current:0
    last:null
  Model:{}
  Collection:{}
  View:{}
  option:
    animation:'fade'
    theme:'default'
  plugins:{}
  pushMethods:{
    'serverpush':true
    'move':true
  }
  isDisplayHelp:false
  userList:{}
  init: (opts={}) ->
    _.each opts, (val,key)->
      sbClient.option[key] = val
    # create slideBase
    wrap = document.createElement 'div'
    wrap.id = 'wrap'
    wrap.display = 'none'
    ctl = document.createElement 'div'
    ctl.id = 'ctl'
    $(ctl).addClass('ctl')
    $(ctl).append "<button class='btn' id='back'>&larr;</button><button class='btn' id='next'>&rarr;</button>"
    help = document.createElement('div')
    help.id = 'help'
    $(help).addClass 'help'
    $(help).addClass 'hide'
    $(help).append "<p id='plgunsHead'>Plugins</p>"
    $('body').append wrap
    $('body').append ctl
    $('body').append help
    $('#plgunsHead').bind 'click', ->
      $('#help').addClass('hide')
      sbClient.isDisplayHelp = false
    slideView = new sbClient.View.SlideView()
    pluginsView = new sbClient.View.PluginView()
  execEmit: (name,data) ->
    console.log "execEmit "+name
    obj =
      name:'plugin'
      plugin:
        name:name
      data:data
    $('body').trigger 'execEmit', obj

# Client Methods
isEnableServerPush = (methodName) ->
  sbClient.pushMethods.serverpush is true and sbClient.pushMethods[methodName] is true

setUserList = (userList) ->
  sbClient.userList = userList

move = (data) ->
  $('body').trigger 'execMove',data


# Backbone
# Model:slide page
sbClient.Model.Slide = Backbone.Model.extend
  elements:''
  page:''

# Collection:all slide pages
sbClient.Collection.Slides = Backbone.Collection.extend
  model: sbClient.Model.Slide

# View: SlideView render per slide
sbClient.View.SlideView = Backbone.View.extend
  el:$('body')
  initialize: ->
    @collection = new sbClient.Collection.Slides()
    num = 0
    self = @
    _.bindAll @, 'render','dispHelp','moveSlide','execMove','handleKey'

    # Bind key event
    self.$el.bind 'keydown', self.handleKey
    # Bind swipe event
    self.$el.bind 'swipeleft', self.moveSlide 1
    self.$el.bind 'swiperight', self.moveSlide -1

    $('#next').bind 'click', ->
      self.moveSlide 1
    $('#back').bind 'click', ->
      self.moveSlide -1

    $('body').on 'execMove',(event,obj) ->
      self.execMove obj.data

    _($(self.el).find 'section' ).each (section) ->
      slide = new sbClient.Model.Slide
        elements:$(section).children()
        page:num
      self.collection.add slide
      num++
    sbClient.page.last = num
    self.render()

  render: ->
    self = @
    append = (className,page,css) ->
      slide = self.collection.at page
      id = slide.get 'page'
      tmp = document.createElement 'div'
      tmp.id = "slide_#{id}"
      $(tmp).addClass(className)
        .append slide.get('elements')
      if css then $(tmp).css css
      resizeSlide()
      $("#wrap").append $(tmp)

    appendAll = (x,y,z) ->
      $("#wrap").addClass "transform"
      self.collection.each (slide, i) ->
        css =
          "transform":"translate3d(#{x*i}px,#{y*i}px,#{z*i}px)"
        if i is 0
          append "slide current transform", 0, css
        else
          append "slide transform", i, css

    switch sbClient.option.animation
      when 'horizontal'
        appendAll $(window).width(), 0, 0
        break
      when 'vertical'
        appendAll 0, $(window).height(), 0
        break
      when 'fade'
        append 'slide current',0
        break
      else
        # TODO
        # Enable aditional animation with plugin
        append 'slide current',0
    sbClient.lock = false

  handleKey: (event) ->
    code  = event.keyCode || event.which
    ctrl  = event.ctrlKey
    alt   = event.altKey
    shift = event.shiftKey
    cmd   = event.metaKey

    if (code is 32) or (code is 39) # space or arrow-right
      if sbClient.isDisplayHelp then return
      event.preventDefault
      @moveSlide 1
    if (code is 8) or (code is 37) # delete or arrow-left
      if sbClient.isDisplayHelp then return
      event.preventDefault
      @moveSlide(-1)
    if (ctrl or cmd) and shift and code is 191
      event.preventDefault
      @dispHelp()

  moveSlide: (direction) ->
    if sbClient.lock then return
    nextpage = sbClient.page.current+direction
    next = @collection.at nextpage
    if next
      obj =
        name:'move'
        data:
          direction:direction
          currentPage:sbClient.page.current
      $('body').trigger 'execEmit', obj
      sbClient.lock = true
      switch sbClient.option.animation
        when 'horizontal'
          horizontalMove direction,nextpage
          break
        when 'vertical'
          verticalMove direction,nextpage
          break
        when 'fade'
          fadeMove next
          break
        else
          # TODO
          # Enable aditional animation with plugin
          fadeMove(next)
      sbClient.page.current = nextpage
      sbClient.lock = false

  execMove: (data) ->
    if data.currentPage is sbClient.page.current
      @moveSlide data.direction

  dispHelp: ->
    console.log "Help!"
    if sbClient.isDisplayHelp
      $('#help').removeClass('disp')
        .addClass('hide')
      sbClient.isDisplayHelp = false
    else
      $('#help').removeClass('hide')
        .addClass('disp')
      sbClient.isDisplayHelp = true

resizeSlide = ->
  $('.slide').each ->
    $(@).css
      'height': $(window).height() - 72
      'width': $(window).width() - 72

fadeMove = (slide) ->
  $('.slide').fadeOut 250,->
    $('.slide').empty()
    $('.slide').append slide.get 'elements'
  $('.slide').fadeIn 500, ->
    sbClient.lock = false

slideMove = (x,y,z,direction,nextpage) ->
  if direction < 0 then direction +=1
  $('#wrap > .slide').each (i,e) ->
    # initposi
    xx = (x * (i - nextpage))
    yy = (y * (i - nextpage))
    zz = (z * (i - nextpage))
    css = "transform":"translate3d(#{xx}px,#{yy}px,#{zz}px)"
    $(e).css css


horizontalMove = (direction,nextpage) ->
  slideMove $(window).width(), 0, 0, direction, nextpage
  sbClient.lock = false

verticalMove = (direction,nextpage) ->
  slideMove 0, $(window).height(), 0, direction, nextpage
  sbClient.lock = false


sbClient.Model.Plugin = Backbone.Model.extend
  defaults:
    name: ''
    callback: ''
    element: ''
    initialScript: ->

sbClient.plugins.serverpush = new sbClient.Model.Plugin
  name: "serverpush"
  element: """
    <div id='#serverpush' class='pluginOption'>
      <input type='checkbox' name='serverpushCheck' value='enable' checked>ServerPush
    </div>
  """
  initialScript: ->
    $('[name="serverpushCheck"]').bind 'change',->
      sbClient.pushMethods.serverpush = $(this).attr("checked") is "checked"

# Collection:all slide pages
sbClient.Collection.Plugins = Backbone.Collection.extend
  model: sbClient.Model.Plugin
  fetch: ->
    self = @
    _.each sbClient.plugins , (plugin)->
      self.add plugin
      sbClient.pushMethods[plugin.get('name')] = true

# View: OverView contains whole slides
sbClient.View.PluginView = Backbone.View.extend
  el: $('#help')
  initialize: ->
    console.log "initialize plugins"
    self = @
    @collection = new sbClient.Collection.Plugins()
    _.bindAll @, 'render'
    @collection.on 'add', (plugin) ->
      self.render plugin
    @collection.fetch()

  render: (plugin) ->
    $('#help').append plugin.get 'element'
    script = plugin.get('initialScript')
    script()

sbClient.View.PluginView.prototype.setPlugin = (plugin) ->
  @collection.add plugin

# socketIO setting
socket = io?.connect "http://#{location.host}"

socket?.on 'error', (reason) ->
  console.error 'Unable to connect Socket.IO', reason

socket?.on 'connect', ->
  console.log 'client connected'

  # Message From Client to Server
  $('body').on 'execEmit', (event,obj) ->
    socket.emit obj.name, obj

  socket.on 'users', (userList) ->
    setUserList userList

  socket.on 'move', (obj) ->
    if not isEnableServerPush 'move' then return false
    move obj

  socket.on 'plugin', (obj) ->
    if not obj.plugin or not obj.plugin.name then return false
    if not isEnableServerPush obj.plugin.name then return false
    func = sbClient.plugins[obj.plugin.name].get("callback") || {}
    func(obj.data)

  socket.on 'disconnect', ->
    # disable event
    $('body').off 'execEmit'
    console.log 'disconnected Bye!'

$ ->
  resizeSlide()

  $(window).bind 'resize',->
    resizeSlide()

  $('a').bind 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()
    window.open @href, '_blank'
