_ = require 'underscore'

Number::mapFloat = (in_min, in_max, out_min, out_max) ->
    parseFloat((this - in_min) * (out_max - out_min) / (in_max - in_min) + out_min)

range = [22, 6]    

Dimmer = 

	norm_range: ->
		offset = Math.abs range[0] - 24
		start = range[0] + offset - 24
		end = range.pop() + offset 

		start: start
		end: end 
		offset: offset

	dim: (time)->
		norm_range = Dimmer.norm_range()
		off_time = time + norm_range.offset
		off_time = if off_time >= 24 then off_time - 24 else off_time
		norm_time1 = off_time.mapFloat norm_range.start, norm_range.end, 1.0, .0
		norm_time2 = off_time.mapFloat norm_range.start, norm_range.end, .0, 1.0
		Math.min(1, Math.max(norm_time1, norm_time2))

module.exports = Dimmer