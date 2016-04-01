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
# Expect airsensor in same folder
spw = cp.spawn './airsensor', ['-j']


app
  .get '/stream', (req, res) ->

    res.writeHead 200,
        'Content-Type':     'text/event-stream'
        'Cache-control':    'no-cache'


    spw.stdout.on 'data',  (data) ->
        out = data.toString()
        lines = out.split "\n"
        #console.log lines.length, lines
        res.write "data: #{lines[0]}\n\n" unless lines.length > 2

    spw.on 'close', (code) ->
        res.end()

    return



http.listen 3001, ->
  console.log 'listening on *:3001'
