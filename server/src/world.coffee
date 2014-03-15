class World
	#this class is responsible for build the game world from database and send it to clients
	constructor: (@name) ->
		@objects = [] #static objects, no ai, cannot-move
		@init()

	init: ->
		#should build world from script
		@width = 800
		@height = 400

	getBound: ->
		#playing area
		return {"x1":0, "x2":@width, "y1":0, "y2":@height}


module.exports = World