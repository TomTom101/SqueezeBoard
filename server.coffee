##############
#
# Server functions
#
##############

cors = require 'cors'
express = require 'express'
app = express()
http = require('http').Server(app)
fs = require 'fs'
app.use cors()

csvWriter = require 'csv-write-stream'
writer = csvWriter()
writeStream = fs.createWriteStream 'airquality.csv',  flags: 'a'
writer.pipe writeStream

cp = require('child_process')

Number::map = (in_min, in_max, out_min, out_max) ->
    Math.round (this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min

# airsensor setup to poll every 20s
poll_every = 20
# Send every x seconds (average of collected values)
send_every = 5 * 60
data_points_to_average = send_every / poll_every
data_array = []
# Expect airsensor in same folder
spw = cp.spawn './airsensor', ['-j']

sumarray = (previous, current) -> current += previous

log_data = (json) ->
  value = json.e[0].v
  data_array.push value
  #console.log "Length is #{data_array.length}"
  if data_array.length % data_points_to_average is 0
    sum = data_array.reduce sumarray
    avg = sum / data_array.length
    air_index = avg.map(450, 2000, 100, 0)
    #console.log "Logging #{air_index} as avg of", data_array
    writer.write
      timestamp: json.e[0].t
      index: air_index
    data_array = []

app
  .get '/stream', (req, res) ->

    res.writeHead 200,
        'Content-Type':     'text/event-stream'
        'Cache-control':    'no-cache'


    spw.stdout.on 'data',  (data) ->
        out = data.toString()
        json  = JSON.parse out
        lines = out.split "\n"
        log_data json
        res.write "data: #{lines[0]}\n\n" unless lines.length > 2

    spw.on 'close', (code) ->
        res.end()

    return



http.listen 3001, ->
  console.log 'listening on *:3001'
