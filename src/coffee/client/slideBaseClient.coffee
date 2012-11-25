###
SlideBaseClient.js
------------------------------------------------
author:  [Takeharu Oshida](http://about.me/takeharu.oshida)
version: 0.1
licence: [MIT](http://opensource.org/licenses/mit-license.php)
###

console.log "This is Client Side Script"

#*****************************
# Namespace
#*****************************
window.sbClient =
  admin:false
  lock:false
  page:
    current:0
    last:null
  Model:{}
  Collection:{}
  View:{}
  Instances:{}
  option:
    animation:''
    theme:'default'
  plugins:{}
  pushMethods:
    'move':true
  isDisplayHelp:false
  userList:{}
  init: (opts={}) ->
    # set option
    _.each opts, (val,key)->
      sbClient.option[key] = val

    # create slideBase
    wrap = document.createElement 'div'
    wrap.id = 'wrap'
    wrap.display = 'none'

    ctl = document.createElement 'div'
    ctl.id = 'ctl'
    $(ctl)
      .addClass('ctl')
      .append "<button class='btn' id='back'>&larr;</button><button class='btn' id='next'>&rarr;</button>"

    help = document.createElement('div')
    help.id = 'help'
    $(help)
      .addClass('help hide')
      .append("<h4 id='usage'><span id='close'>✖</span>&nbsp;Usage</h4>")

    $('body')
      .append(wrap)
      .append(ctl)
      .append(help)

    $('#close').bind 'click', ->
      $('#help').addClass('hide')
      sbClient.isDisplayHelp = false

    @Instances.slideView = new sbClient.View.Slide()
    # @Instances.pluginView = new sbClient.View.Plugin()

  #*****************************
  # Client Methods
  #*****************************
  resizeSlide: ->
    $('.slide').each ->
      $(@).css
        'height': $(window).height() - 72
        'width': $(window).width() - 72

  execEmit:(name,data) ->
    console.log "execEmit "+name
    obj =
      name:'plugin'
      plugin:
        name:name
      data:data
    $('body').trigger 'execEmit', obj

  isEnableServerPush:(method) ->
    @pushMethods[method]

  isEnablePlugin:(obj) ->
    if not obj.plugin or not obj.plugin.name then return false
    @isEnableServerPush obj.plugin.name

  move:(obj) ->
    if @isEnableServerPush 'move'
      @Instances.slideView.trigger 'execMove',obj.data

  setUserList:(userList) ->
    @userList = userList

  nextSlide:(slide) ->
    tmp = document.createElement 'div'
    tmp.id = "slide_#{slide.get 'page'}"
    $(tmp)
      .addClass(slide.get('class'))
      .addClass('slide current')
      .append(slide.get('elements'))

  simpleMove:(slide) ->
    next = @nextSlide(slide)
    $('#wrap')
      .empty()
      .removeClass()
      .append(next)
    @resizeSlide()
    @lock = false

  fadeMove:(slide) ->
    next = @nextSlide(slide)
    $('#wrap').fadeOut 250,->
      $('#wrap')
        .empty()
        .removeClass()
        .append(next)
      sbClient.resizeSlide()
    $('#wrap').fadeIn 500, ->
      @lock = false

  positionMove:(x,y,z,direction,nextpage) ->
    if direction < 0 then direction +=1
    $('#wrap > .slide').each (i,e) ->
      # initposi
      xx = (x * (i - nextpage))
      yy = (y * (i - nextpage))
      zz = (z * (i - nextpage))
      css = "transform":"translate3d(#{xx}px,#{yy}px,#{zz}px)"
      $(e).css css

  horizontalMove:(direction,nextpage) ->
    @positionMove $(window).width(), 0, 0, direction, nextpage
    @lock = false

  verticalMove:(direction,nextpage) ->
    @positionMove 0, $(window).height(), 0, direction, nextpage
    @lock = false

#*****************************
# Presentation Backbone
#*****************************
# Model:slide page
sbClient.Model.Slide = Backbone.Model.extend
  elements:''
  class:''
  page:''

# Collection:all slide pages
sbClient.Collection.Slides = Backbone.Collection.extend
  model: sbClient.Model.Slide
  fetch: ->
    self = @
    _($('section')).each (section,index) ->
      slide = new sbClient.Model.Slide
        elements:$(section).contents()
        class:$(section).attr('class')
        page:index
      self.add slide
      $(section).remove()
    sbClient.page.last = self.length
    self.trigger 'ready'

# View: SlideView render per slide
sbClient.View.Slide = Backbone.View.extend
  el:$('body')
  initialize: ->
    self = @
    self.collection = new sbClient.Collection.Slides()
    _.bindAll @, 'render','dispHelp','moveSlide','handleKey'

    # Bind key event
    self.$el.bind 'keydown', self.handleKey
    # Bind swipe event
    self.$el.bind 'swipeleft', self.moveSlide 1
    self.$el.bind 'swiperight', self.moveSlide -1
    # Bind click event
    $('#next').bind 'click', ->
      self.moveSlide 1
    $('#back').bind 'click', ->
      self.moveSlide -1
    # Bind server push
    self.on 'execMove',(event) ->
      args = Array.prototype.slice.apply arguments
      data = args[0]
      if data.currentPage is sbClient.page.current then self.moveSlide data.direction

    self.collection.on 'ready',->
      self.render()

    self.collection.fetch()

  render: ->
    self = @
    append = (className,page,css) ->
      slide = (self.collection.where page:page)[0]
      id = slide.get 'page'
      tmp = document.createElement 'div'
      tmp.id = "slide_#{id}"
      $(tmp)
        .addClass(className)
        .addClass(slide.get('class'))
        .append(slide.get('elements'))
      if css then $(tmp).css css
      sbClient.resizeSlide()
      $("#wrap").append $(tmp)

    appendAll = (x,y,z) ->
      self.collection.each (slide, i) ->
        css =
          "transform":"translate3d(#{x*i}px,#{y*i}px,#{z*i}px)"
        if i is 0
          append "slide current transform", 0, css
          location.hash = i
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
    self = @
    if sbClient.lock then return
    nextpage = sbClient.page.current+direction
    next = self.collection.at nextpage
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
          sbClient.horizontalMove direction,nextpage
          break
        when 'vertical'
          sbClient.verticalMove direction,nextpage
          break
        when 'fade'
          sbClient.fadeMove next
          break
        else
          # TODO
          # Enable aditional animation with plugin
          sbClient.simpleMove next
      sbClient.page.current = nextpage
      location.hash = sbClient.page.current
      sbClient.lock = false

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

#*****************************
# Plugins setting Backbone
#*****************************
# Model:slide Plugin
sbClient.Model.Plugin = Backbone.Model.extend
  defaults:
    id: ''
    name: ''
    callback: ''
    element: ''
    initialScript: ->

  initialize:->
    self = @
    $ ->
      name = self.get 'name'
      sbClient.plugins[name] = self
      sbClient.pushMethods[name] = true
      $('#help').append self.get('element')
      script = self.get('initialScript') || {}
      script()

# # Collection:all plugins
# sbClient.Collection.Plugins = Backbone.Collection.extend
#   model: sbClient.Model.Slide

# # View: plugins
# sbClient.View.Plugin = Backbone.View.extend
#   el: $('#help')
#   initialize: ->
#     self = @
#     self.collection = new sbClient.Collection.Plugins()
#     _.bindAll @, 'render'
#     self.collection.on 'add',(plugin) ->
#       self.render plugin

#   render: (plugin)->
#     $('#help').append plugin.get 'element'
#     script = plugin.get('initialScript') || {}
#     script()

#*****************************
# socket.IO setting
#*****************************
socket = io?.connect "http://#{location.host}"

socket?.on 'error', (reason) ->
  console.error 'Unable to connect Socket.IO', reason

socket?.on 'connect', ->
  console.log 'client connected'

  # Message From Clients to Server
  $('body').on 'execEmit', (event,obj) ->
    socket.emit obj.name, obj

  # Message From Server to Clients
  socket.on 'users', (userList) ->
    sbClient.setUserList userList

  socket.on 'move', (obj) ->
    sbClient.move obj

  socket.on 'plugin', (obj) ->
    if sbClient.isEnablePlugin obj
      func = sbClient.plugins[obj.plugin.name].get("callback") || {}
      func(obj.data)

  socket.on 'disconnect', ->
    # disable event
    $('body').off 'execEmit'
    console.log 'disconnected Bye!'

#*****************************
# DOM ready
#*****************************
$ ->

  sbClient.resizeSlide()

  $(window).bind 'resize',->
    sbClient.resizeSlide()

  $('a').bind 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()
    window.open @href, '_blank'
