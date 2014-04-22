class window.World
	constructor: (@canvas, @bar, @players = [],@objects = []) ->
		# Root container
		@world = new createjs.Container()
		@world.x = 0
		@world.y = 100
		@hud = new createjs.Container()
		@width = @canvas.width
		@height = @canvas.height - 100
		@objects   #all non-character sprites
		@players   #player characters and robots
		@init()

	init: ->
		@stage = new createjs.Stage @canvas
		@statusBar = new createjs.DOMElement(@bar)
		@hud.addChild(@statusBar)
		@stage.addChild @hud
		#add a help text to screen
		@helpText = new createjs.Text("Waiting for player...", "20px Arial", "#ff7700")
		@helpText.x = 300
		@helpText.y = 100
		@helpText.textBaseline = "alphabetic"
		@world.addChild @helpText


	build: (world) ->
		#should build world from server data
		@background = new createjs.Bitmap(world.backgroundURL)
		@background.name = "background"
		@world.addChild(@background)
		for object in world.objects
			spriteSheet = new createjs.SpriteSheet object.spriteSheetInfo
			AnimatedObject = new createjs.BitmapAnimation spriteSheet
			AnimatedObject.x = object.x
			AnimatedObject.y = object.y
			@world.addChild AnimatedObject
		@stage.addChild @world

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
				return

	removePlayer:(target) ->
		for player,index in @players
			if player.id == target.id
				@world.removeChild player.get()
				@players.splice index,1
				return

	removeById:(id) ->
		player = @getPlayer id
		if player != null
			@removePlayer player
			return true
		object = @getObject id
		if object != null
			@removeObject object
			return true
		return false

	getPlayer: (id) ->
		for player in @players
			if player.id == id
				return player
		return null

	getObject: (id) ->
		for object in @objects
			if object.id == id
				return object
		return null

	getBound: ->
		#playing area
		return {"x1":0, "x2":@background.image.width, "y1":0, "y2":@background.image.height}

	playerExists: (id) ->
		for p in @players
			if (p.id == id)
				return true
		return false

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
 
