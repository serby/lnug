var http = require('http'),
  jsonsp = require('jsonsp'),
  parser = new jsonsp.Parser();


function Vimeo(opt) {
  this.videos = [];
  this.keyword; // Keyword to filter videos by.
}

Vimeo.prototype.request = function(user, type) {
  // requests videos from a user given the name of the user and what you want returned.
  var options, req, self = this;


  type = type || 'videos';
  options = {
    host: "vimeo.com",
    path: "/api/v2/" + user + "/" + type + ".json",
    port: 80,
  }

  http.get(options, function(res) {
    res.on('data', function(chunk) {
      parser.parse(chunk.toString('utf8'));
    })

    parser.on('object', function(obj) {
      self.format(obj);
    });
  }).on('error', function(e) {
    console.log("Error: " + e.message);
  })
}

Vimeo.prototype.format = function(data) {
  this.videos = [];

  for(var v=0; v < data.length; v++) {
    if(this.keyword && data[v].tags.indexOf(this.keyword.toLowerCase()))
      continue;
    
    this.videos.push(data[v]);
  }
}

module.exports = new Vimeo();
