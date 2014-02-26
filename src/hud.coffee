class window.Hud
	constructor: (@players, @w, @h, @stage) ->
		# Top level container for HUD
		@container = new createjs.Container();
		@container.x = 0
		@container.y = 0

		# Background for HUD
		background = new createjs.Graphics().beginFill("#3D414C").drawRect 0, 0, @w, @h
		@shape = new createjs.Shape background
		@shape.x = 0
		@shape.y = 0
		
		g = new createjs.Graphics()
		g.setStrokeStyle 1
		g.beginStroke (createjs.Graphics.getRGB 0,0,0 )
		g.beginFill (createjs.Graphics.getRGB 255,0,0 )
		g.drawRoundRect 0,0,30,30,3

		s = new createjs.Shape(g);
		s.x = 100;
		s.y = 100;

		@init()

	init: ->
		@container.addChild @shape
		




		@stage.addChild @container










