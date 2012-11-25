// Generated by CoffeeScript 1.3.3

/*
slideBaseClient-plugin-alone.js
------------------------------------------------
author:  [Takeharu Oshida](http://about.me/takeharu.oshida)
version: 0.1
licence: [MIT](http://opensource.org/licenses/mit-license.php)
*/


(function() {
  var alone;

  alone = new sbClient.Model.Plugin({
    name: "alone",
    element: "<div id='#alone' class='pluginOption'>\n  <input type='checkbox' name='alone' value='enable'>Leave me alone\n</div>",
    initialScript: function() {
      return $('[name="alone"]').bind('change', function() {
        var self;
        self = this;
        return _.each(sbClient.pushMethods, function(value, key) {
          return sbClient.pushMethods[key] = !($(self).attr("checked") === 'checked');
        });
      });
    }
  });

}).call(this);