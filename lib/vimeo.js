var http = require('http'),
  jsonsp = require('jsonsp'),
  parser = new jsonsp.Parser();


function Vimeo(opt) {
  this.videos = [];
  this.keyword; // Keyword to filter videos by.
  this.user = 'forwardtechnology';
  this.type = 'videos';

  console.log(opt)
}

parser.on('object', function(obj, data) {
  obj.format(data);
});

Vimeo.prototype.request = function() {
  // requests videos from a user given the name of the user and what you want returned.
  var options, req, self = this;

  options = {
    host: "vimeo.com",
    path: "/api/v2/" + this.user + "/" + this.type + ".json",
    port: 80,
  }

  http.get(options, function(res) {
    res.on('data', function(chunk) {
      parser.parse(self, chunk.toString('utf8'));
    })
  }).on('error', function(e) {
    console.log("Error: " + e.message);
  })
}

Vimeo.prototype.format = function(data) {
  this.videos = [];

  for(var v=0; v < data.length; v++) {
    if(this.keyword && data[v].tags.toLowerCase().indexOf(this.keyword.toLowerCase()) < 0)
      continue;
    
    this.videos.push(data[v]);
  }
}

module.exports = new Vimeo();
