class window.World
	constructor: (@canvas, @players = [],@objects = []) ->
		# Root container
		@world = new createjs.Container()
		@world.x = 0
		@world.y = 0
		@width
		@height
		@objects
		@players
		@init()

	init: ->
		@stage = new createjs.Stage @canvas
		@width = @stage.canvas.width
		@height = @stage.canvas.height
		@build()

	build: () ->
		#should build world from script
		@background = new createjs.Bitmap("assets/background/1.png")
		@world.addChild(@background);
		for object in @objects
			console.log 'add'
			@world.addChild object.get()
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

	addPlayer: (player) ->
		@world.addChild player.get()
		@objects.push player
		@players.push player

	addObject: (object) ->
		@world.addChild object.get()
		@objects.push object

	removeObject:(target) ->
		for object,index in @objects
			if object.id == target.id
				@objects.splice index,1

	removePlayer:(target) ->
		for player,index in @playerss
			if player.id == target.id
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

############ detect collision of objects ##############
	detectCollision: (e) ->
		object_list = []
		if @objects.length == 0
			return
		for object,index in @objects
			if object in object_list or not object?
				continue
			pair = object.detectCollision()
			for o in pair
				object_list.push o

