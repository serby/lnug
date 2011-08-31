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

app.get "/", (req,res) ->
    res.render 'lnug.html', layout: false

port = process.env.PORT || 8080
app.listen port
console.log "Listening on Port '#{port}'"

        
        
