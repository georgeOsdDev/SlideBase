###
slideBaseClient-plugin-alone.js
------------------------------------------------
author:  [Takeharu Oshida](http://about.me/takeharu.oshida)
version: 0.1
licence: [MIT](http://opensource.org/licenses/mit-license.php)
###
alone = new sbClient.Model.Plugin
  name: "alone"
  element: """
    <div id='#alone' class='pluginOption'>
      <input type='checkbox' name='alone' value='enable'>Leave me alone
    </div>
  """
  initialScript: ->
    $('[name="alone"]').bind 'change',->
      self = @
      _.each sbClient.pushMethods, (value,key)->
        sbClient.pushMethods[key] = !($(self).attr("checked") is 'checked')