express = require 'express'
sizlate = require 'sizlate'
mongoose = require 'mongoose'
require 'datejs'
md = require("node-markdown").Markdown

mongoose.connect process.env['MONGOHQ_URL'] || 'mongodb://localhost/lnug'

Schema = mongoose.Schema
ObjectId = Schema.ObjectId

app = express.createServer()

app.register '.html', require('ejs')
app.register '.html', sizlate

app.configure ->
  app.use(express.bodyParser())
  app.set('dirname', __dirname)
  app.use(app.router)
  app.use(express.static(__dirname + "/public/"))
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true}))
  app.set('views',__dirname + "/views/")

vimeo = require('./lib/vimeo')
vimeo.keyword = 'LNUG'
vimeo.request()

JobSchema = new Schema
  job_title     : { type: String, required: true }
  description   : { type: String, required: true }
  name          : { type: String, required: true }
  email         : { type: String, required: true }
  company_name  : { type: String, required: true }
  company_url   : { type: String, required: true }
  location      : { type: String, required: true }
  type          : { type: String, required: true }
  date          : { type: Date,   default: Date.now }

Job = mongoose.model 'Job', JobSchema

# server routes
app.get "/", (req,res) ->
  videos = vimeo.videos[0..3].map (v) ->
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

app.get '/jobs', (req,res) ->
  Job.where('date').gt(Date.parse('-30days')).sort('date',-1).run (err, docs) ->
    if docs
      jobs = docs.map (j) ->
        {
          date: j.date.toDateString(),
          company: {
            href: j.company_url,
            innerHTML: j.company_name
          },
          type: j.type
          location: j.location,
          title: j.job_title,
          description: md(j.description, true),
          apply: {
            href: "mailto:#{j.email}"
          }
        }
    else
      jobs = []

    res.render 'jobs.html',
      selectors: {
        'ul#jobs':{
          partial: 'job.html',
          data: jobs
        }
      }

app.get '/submit', (req,res) ->
  res.render 'submit.html',
    selectors: {}

app.post '/submit', (req,res) ->
  job = new Job(req.body)
  if req.body.password == process.env['JOB_PASSWORD']
    job.save (err) ->
      if err
        console.log(err)
        res.render 'submit.html',
           selectors: {
             '.error': 'Invalid submission, all fields are required'
           }
      else
        res.redirect '/jobs'
  else
    res.render 'submit.html',
       selectors: {
         '.error': 'Invalid password'
       }

sizlate.startup app, (app) ->
  port = process.env.PORT || 8080
  app.listen port
  console.log "Listening on Port '#{port}'"