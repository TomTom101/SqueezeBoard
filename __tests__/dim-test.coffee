jest.dontMock '../app/clock/scripts/DimmerService'
jest.dontMock 'underscore'


describe 'dim', ->

	it 'dims to 1 at 22:00', ->
		Dimmer = require '../app/clock/scripts/DimmerService'
		expect Dimmer.dim 22
			.toBe 1

	it 'dims to .5 at 02:00', ->
		Dimmer = require '../app/clock/scripts/DimmerService'
		expect Dimmer.dim 2
			.toBe .5

	it 'dims to 1 at 6:00', ->
		Dimmer = require '../app/clock/scripts/DimmerService'
		expect Dimmer.dim 6
			.toBe 1

	it 'dims to 1 at 14:00', ->
		Dimmer = require '../app/clock/scripts/DimmerService'
		expect Dimmer.dim 14
			.toBe 1
