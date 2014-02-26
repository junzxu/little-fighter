class window.Arena
	constructor: (@w, @h, @players = {}) ->

		# Root container for battle arena
		@container = new createjs.Container();
		@container.x = 0;
		@container.y = 0;
		# Background for arena
		@background = new createjs.Bitmap("assets/background/1.png");
		@container.addChild(@background);
		@init()

	init: ->
		for p in @players
			console.log 'add'
			@container.addChild p.getPlayer()

	setPosition: (x, y) ->
		@container.x = x
		@container.y = y

	addPlayer: (player) ->
		@container.addChild player.getPlayer()
		@players.push player

	addToStage: (stage) ->
		stage.addChild @container

	getPlayers: ->
		return @players

	getBound: ->
		return {"x1":0, "x2":@background.image.width, "y1":0, "y2":@background.image.height}