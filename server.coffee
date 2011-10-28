express = require 'express'

app = express.createServer()

app.register '.html', require('ejs')

app.configure ->
  app.use(express.bodyParser())
  app.use(app.router)
  app.use(express.static(__dirname + "/public/"))
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true}))
  app.set('views',__dirname + "/views/")
  
# server routes
vimeo = require('./lib/vimeo')
vimeo.keyword = 'LNUG'

app.get "/", (req,res) ->
  videos = vimeo.request('forwardtechnology')
  console.log vimeo.keyword
  res.render 'lnug.html', layout: false, locals:
                                            videos = vimeo.videos

port = process.env.PORT || 8080
app.listen port
console.log "Listening on Port '#{port}'"
