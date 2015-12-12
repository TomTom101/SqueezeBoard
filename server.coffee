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

exec = require('child_process').exec
cmd = "/home/pi/airsensor/airsensor -o -j"



returnAirsensorData = (res) ->
    console.log "Getting getAirsensorData"
    exec cmd, (error, stdout, stderr) ->
        console.log stdout
        res.setHeader 'Content-Type', 'application/json'
        res.send stdout

app
  .get '/', (req, res) ->
    returnAirsensorData res


http.listen 3001, ->
  console.log 'listening on *:3001'
