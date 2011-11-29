express = require 'express'
sizlate = require 'sizlate'

app = express.createServer()

app.register '.html', require('ejs')
app.register '.html', sizlate

app.configure ->
  app.use(express.bodyParser())
  app.use(app.router)
  app.use(express.static(__dirname + "/public/"))
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true}))
  app.set('views',__dirname + "/views/")

vimeo = require('./lib/vimeo')
vimeo.keyword = 'LNUG'
vimeo.request()

# server routes
app.get "/", (req,res) ->
  videos = vimeo.videos.map (v) ->
    {
      title: v.title,
      a: {
        href: v.url
      },
      thumb: {
        src: v.thumbnail_medium,
        alt: v.title
      }
    }

  res.render 'index.html',
    selectors: {
      'ul#videos':{
        partial: 'video.html',
        data: videos
      }
    }


sizlate.startup app, (app) ->
  port = process.env.PORT || 8080
  app.listen port
  console.log "Listening on Port '#{port}'"