class window.object
    constructor: (@id, @name, @type, @x, @y, @world) ->
        @id
        @type
        @hp
        @mass = 1
        @speed = 0  #current speed
        @originSpeed = 2
        @collisionHeight = 20
        @collisionWidth = 30
        @spriteSheetInfo
        @SpriteSheet
        @sprite = null
        @objectSpriteSheet
        @direction
        @world
        @magicState = "ready"

    init: ->
    	#load spriteSheet, do extra init in child class
    	if @spriteSheetInfo
    		@SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo

    get: ->
    	#override in child class
    	return @sprite

    counterDirection: (direction) ->
    	switch direction
    		when "right"
    			return "left"
    			break
    		when "left"
    			return "right"
    			break
    		when "up"
    			return "down"
    			break
    		when "down"
    			return "up"
    			break
    		when "No"
    			return "No"

    reverseDirection: ->
    	@direction = @counterDirection(@direction)
    	console.log(@name + ' reversed to ' + @direction)

    moveStep: (direction) =>
	    bound = @world.getBound()
	    switch direction
	        when "left"
	            if (@direction != "left")
	                @direction = "left"
	            if(@get().x - @speed > bound['x1'])
	                @get().x -= @speed
	            else
	                @get().x += @speed
	        when "right"
	            if (@direction != "right")
	                @direction = "right"
	            if(@get().x + @speed < bound['x2'])
	                @get().x += @speed
	            else
	                @get().x -= @speed
	        when "down"
	            @direction = "down"
	            if(@get().y + @speed < bound['y2'])
	                @get().y += @speed
	            else
	                @get().y -= @speed
	        when "up"
	            @direction = "up"
	            if(@get().y - @speed > bound['y1'])
	                @get().y -= @speed
	            else
	                @get().y += @speed
	    @updateCoords()

    moveTo: (x,y)->
	    bound = @world.getBound()
	    if (x  > bound['x1'] and x < bound['x2'] and y  > bound['y1'] and y < bound['y2'])
	        @get().x = x
	        @get().y = y
	        @updateCoords()
	    else
	       console.log('invalid coordinates: (' + x + ',' + y + ')')


    getRect: ->
        x1 = @get().getBounds().x + @get().x
        y1 = @get().getBounds().y + @get().y
        x2 = @get().getBounds().x + @get().x + @get().getBounds().width
        y2 = @get().getBounds().y + @get().y + @get().getBounds().height
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    getCollisionRect: ->
        x1 = @get().getBounds().x + @get().x + @collisionWidth
        y1 = @get().getBounds().y + @get().y + @collisionHeight
        x2 = @get().getBounds().x + @get().x + @get().getBounds().width - @collisionWidth
        y2 = @get().getBounds().y + @get().y + @get().getBounds().height - @collisionHeight
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    gotHit: (direction) ->
        console.log("got hit")

################################################################