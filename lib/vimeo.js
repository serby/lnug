var http = require('http');

function Vimeo() {
  var self = this;

  this.videos = [];
  this.keyword; // Keyword to filter videos by.
  this.user = 'forwardtechnology';
  this.type = 'videos';
}

Vimeo.prototype.request = function() {
  var self = this;
  // requests videos from a user given the name of the user and what you want returned.
  var options;
  var data = ''

  options = {
    host: "vimeo.com",
    path: "/api/v2/" + this.user + "/" + this.type + ".json",
    port: 80,
  }

  http.get(options, function(res) {
    res.on('data', function(chunk) {
      data += chunk
    });
    res.on('end', function(){
      self.format(JSON.parse(data));
    })

  }).on('error', function(e) {
    console.log("Error: " + e.message);
  })
}

Vimeo.prototype.format = function(data) {
  var received_videos = [];
  for(var v=0; v < data.length; v++) {
    if(this.keyword && data[v].tags.toLowerCase().indexOf(this.keyword.toLowerCase()) < 0)
      continue;

    received_videos.push(data[v]);
  }
  this.videos = received_videos;
}

module.exports = new Vimeo();
