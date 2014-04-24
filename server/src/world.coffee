Item = require("./item.js")
UUID = require('node-uuid')

class World
	#this class is responsible for build the game world from database and send it to clients
	constructor: (@name) ->
		@objects = [] #objects initally exist
		@init()

	init: ->
		#should build world from script
		@width = 800
		@height = 400
		@backgroundURL = "/assets/background/1.png"

		item_id = UUID()
		bound = @getBound() 
		rock = new Item item_id, "rock", 300, 300, bound
		@objects.push rock

	getBound: ->
		#playing area
		return {"x1":0, "x2":@width, "y1":0, "y2":@height}


module.exports = World