class Object
	constructor: (@name, @type, @x, @y, @stage, @arena) ->
        @id
        @type
        @hp
        @mass = 1
        @speed
        @spriteSheetInfo
        @object = null
        @objectSpriteSheet
        @direction = "right"
        @stage
        @arena
        @magicState = "ready"
        @init()

    init:()->
    	#build SpriteSheet and Sprite
    	return

    get:()->
    	#override in child class
    	return @object

    changeDirection: (direction) ->
        @direction = direction
        @get().scaleX = -@get().scaleX

    reverseDirection:() ->
    	switch @direction
    		when "right"
    			@direction = "left"
    		when "left"
    			@direction = "right"
    		when "up"
    			@direction = "down"
    		when "down"
    			@direction = "up"

    moveStep: (direction)->
	    bound = @arena.getBound()
	    switch direction
	        when "left"
	            if (@direction != "left")
	                @changeDirection "left"
	            if(@get().x - @speed > bound['x1'])
	                @get().x -= @speed
	            else
	                @get().x += @speed
	        when "right"
	            if (@direction != "right")
	                @changeDirection "right"
	            if(@get().x + @speed < bound['x2'])
	                @get().x += @speed
	            else
	                @get().x -= @speed
	        when "down"
	            if(@get().y + @speed < bound['y2'])
	                @get().y += @speed
	            else
	                @get().y -= @speed
	        when "up"
	            if(@get().y - @speed > bound['y1'])
	                @get().y -= @speed
	            else
	                @get().y += @speed

	moveTo: (x,y)->
	    bound = @arena.getBound()
	    if (x  > bound['x1'] and x < bound['x2'] and y  > bound['y1'] and y < bound['y2'])
	        @get().x = x
	        @get().y = y
	    else
	    	console.log('invalid coordinates: (' + x + ',' + y + ')')

    getRect: ->
        x1 = @get().getBounds().x + @get().x
        y1 = @get().getBounds().y + @get().y
        x2 = @get().getBounds().x + @get().x + @get().getBounds().width
        y2 = @get().getBounds().y + @get().y + @get().getBounds().height
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    detectCollision: () ->
        object = @get
        if not object?
            return
        rect1 = object.getRect()
        for otherObject in @arena.getObjects()
          rect2 = otherObject.getRect()
          if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
            @collisionHandler(object,otherObject)

    updateSpeed: (a,b) ->
    	v1 = a.speed
    	v2 = b.speed
		a.reverseDirection()
		a.speed = Math.abs(a.mass-b.mass)/(a.mass+b.mass)*v1
		a.speed += (2*b.mass)/(a.mass + b.mass)*v2
		b.reverseDirection()
		b.speed = (2*b.mass)/(a.mass + b.mass)*v1
		b.speed += Math.abs(a.mass-b.mass)/(a.mass+b.mass)*v2


    collisionHandler: ()->
    	#override in child class
    	@updateSpeed()