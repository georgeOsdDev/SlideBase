var SlideBase = require('./lib/slideBase');
SlideBase.startSlide();

process.on('uncaughtException', function(err){
  console.log("uncoughtException: " + err);
});
  
