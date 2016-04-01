var app, cors, cp, express, http, spw;

cors = require('cors');

express = require('express');

app = express();

http = require('http').Server(app);

app.use(cors());

cp = require('child_process');

spw = cp.spawn('./airsensor', ['-j']);

app.get('/stream', function(req, res) {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-control': 'no-cache'
  });
  spw.stdout.on('data', function(data) {
    var lines, out;
    out = data.toString();
    lines = out.split("\n");
    if (!(lines.length > 2)) {
      return res.write("data: " + lines[0] + "\n\n");
    }
  });
  spw.on('close', function(code) {
    return res.end();
  });
});

http.listen(3001, function() {
  return console.log('listening on *:3001');
});
