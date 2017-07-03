##############
#
# Server functions
#
##############

cors = require 'cors'
express = require 'express'
app = express()
http = require('http').Server(app)
moment = require 'moment'
KeenTracking = require 'keen-tracking'

#// This is your actual Project ID and Write Key
keenio = new KeenTracking
    projectId: '5958f9fdbe8c3e85dbe0c881',
    writeKey: 'F5632AD9F4465A114E437DAF44A5958CA52C6AC4EFD7CDBA37ED0409B5B26EA029D60874FF6573EC11F0A8A6C7A2CF04B6E8EFD93E60CD3E4361EC28F772246D8B80F7BE11E8481D70B6CBD078C113F1DEF53D7E619CC6CC66B106412333EA8B'

app.use cors()

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
  if data_array.length >= data_points_to_average
    sum = data_array.reduce sumarray
    avg = sum / data_array.length
    air_index = avg.map(450, 2000, 100, 0)
    #console.log "log_data called at #{moment().format('h:mm:ss SSS')} with #{data_array.length} entries"
    data_array = []
    keenio.recordEvent 'airquality',
        q: air_index
        weekday: moment().isoWeekday()
        is_weekend: moment().isoWeekday() > 5


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
