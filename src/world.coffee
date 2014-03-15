class window.World
	constructor: (@canvas, @bar, @players = [],@objects = []) ->
		# Root container
		@world = new createjs.Container()
		@world.x = 0
		@world.y = 100
		@hud = new createjs.Container()
		@width = @canvas.width
		@height = @canvas.height - 100
		@objects
		@players
		@init()

	init: ->
		@stage = new createjs.Stage @canvas
		@build()

	build: () ->
		#should build world from script
		@background = new createjs.Bitmap("assets/background/1.png")
		@world.addChild(@background)
		for object in @objects
			console.log 'add'
			@world.addChild object.get()
		@stage.addChild @world

		@statusBar = new createjs.DOMElement(@bar)
		@hud.addChild(@statusBar)
		@stage.addChild @hud

	moveCamera:(x,y) ->
		Xdiff = x - @background.x
		Ydiff = y - @background.y
		@background.x = x
		@background.y = y
		for object in objects
			object.get().x += Xdiff
			object.get().y += Ydiff 


	setPosition: (x, y) ->
		@world.x = x
		@world.y = y

	addPlayer: (player,number = 0) ->
		@world.addChild player.get()
		@objects.push player
		@players.push player
		player.number ?= number

	addObject: (object) ->
		@world.addChild object.get()
		@objects.push object

	removeObject:(target) ->
		for object,index in @objects
			if object.id == target.id
				@world.removeChild object.get()
				@objects.splice index,1

	removePlayer:(target) ->
		for player,index in @playerss
			if player.id == target.id
				@world.removeChild object.get()
				@players.splice index,1

	getPlayers: ->
		return @players

	getObjects: ->
		return @objects

	getBound: ->
		#playing area
		return {"x1":0, "x2":@background.image.width, "y1":0, "y2":@background.image.height}

	get: ->
		return @world

	getNearestCharacter: (origin) ->
 		character = origin.get()
 		distance = 100000
 		index = 0
 		target = null
 		for player in @players
 			if player.number == origin.number
 				continue
 			c = player.get()
 			d = Math.pow((character.x - c.x),2) + Math.pow((character.y - c.y),2)
 			if d < distance
 				distance = d
 				target = player
 		d = Math.sqrt(distance)
 		[target,d]
 