var app, cors, cp, csvWriter, data_array, data_points_to_average, express, fs, http, log_data, poll_every, send_every, spw, sumarray, writeStream, writer;

cors = require('cors');

express = require('express');

app = express();

http = require('http').Server(app);

fs = require('fs');

app.use(cors());

csvWriter = require('csv-write-stream');

writer = csvWriter();

writeStream = fs.createWriteStream('airquality.csv', {
  flags: 'a'
});

writer.pipe(writeStream);

cp = require('child_process');

Number.prototype.map = function(in_min, in_max, out_min, out_max) {
  return Math.round((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min);
};

poll_every = 20;

send_every = 5 * 60;

data_points_to_average = send_every / poll_every;

data_array = [];

spw = cp.spawn('./airsensor', ['-j']);

sumarray = function(previous, current) {
  return current += previous;
};

log_data = function(json) {
  var air_index, avg, sum, value;
  value = json.e[0].v;
  data_array.push(value);
  if (data_array.length % data_points_to_average === 0) {
    sum = data_array.reduce(sumarray);
    avg = sum / data_array.length;
    air_index = avg.map(450, 2000, 100, 0);
    writer.write({
      timestamp: new Date().toISOString(),
      index: air_index
    });
    return data_array = [];
  }
};

app.get('/stream', function(req, res) {
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-control': 'no-cache'
  });
  spw.stdout.on('data', function(data) {
    var json, lines, out;
    out = data.toString();
    json = JSON.parse(out);
    lines = out.split("\n");
    log_data(json);
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
