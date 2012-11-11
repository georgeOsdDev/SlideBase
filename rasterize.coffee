page = new WebPage()

address     = phantom.args[0] || 'http://localhost:3000'
pageLength  = phantom.args[1] || 10
output      = phantom.args[2] || "png"
width       = phantom.args[3] || 1366
height      = phantom.args[4] || 768
paperwidth  = phantom.args[5] || '48.77cm'
paperheight = phantom.args[6] || '17.43cm'


page.viewportSize =
  width: width
  height: height
page.paperSize =
  width: paperwidth
  height: paperheight
  border: '0px'

page.open address, (status) ->
  console.log status
  if status is not 'success'
    console.log 'error!'
  else
    page.includeJs 'http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js',->
      nowPage = 1
      nextPage = ->
        offset = page.evaluate ->
          $('#next').offset()
        page.sendEvent 'click', offset.left+1, offset.top+1
        setTimeout ->
          page.render "#{nowPage}_.#{output}"
          console.log "#{nowPage} finish"
          nowPage++
          if nowPage <= pageLength
            nextPage()
          else
            console.log "allPage finish"
            console.log "Use preview.app to convert png to PDF :-)"
            phantom.exit()
        , 3000

      # firstPage
      setTimeout ->
        console.log "#{nowPage}_.#{output}"
        page.render "#{nowPage}_.#{output}"
        console.log "firstpage finish"
        nowPage++
        nextPage()
      , 2000

