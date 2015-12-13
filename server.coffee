##############
#
# Server functions
#
##############

cors = require 'cors'
express = require 'express'
app = express()
http = require('http').Server(app)

app.use cors()

cp = require('child_process')
cmd = "/home/pi/airsensor/airsensor -o -j"

app
  .get '/stream', (req, res) ->

    res.writeHead 200,
        'Content-Type':     'text/event-stream'
        'Cache-control':    'no-cache'
        'Connection':       'keep-alive'

    spw = cp.spawn '/home/pi/airsensor/airsensor', ['-j']

    spw.stdout.on 'data',  (data) ->
        out = data.toString()
        lines = out.split "\n"
        console.log lines.length, lines
        res.write "data: #{lines[0]}\n\n" unless lines.length > 2

    spw.on 'close', (code) ->
        res.end str



http.listen 3001, ->
  console.log 'listening on *:3001'
