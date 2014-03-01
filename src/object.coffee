class window.Object
	constructor: (@name, @type, @x, @y, @stage, @arena) ->
        @id
        @type
        @hp
        @mass = 1
        @speed = 0  #current speed
        @originSpeed = 5
        @spriteSheetInfo
        @SpriteSheet
        @object = null
        @objectSpriteSheet
        @direction
        @stage
        @arena
        @magicState = "ready"
        @init()

    init:() ->
    	#load spriteSheet, do extra init in child class
    	if @spriteSheetInfo
    		@SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo

    get: ->
    	#override in child class
    	return @object

    reverseDirection: ->
    	switch @direction
    		when "right"
    			@direction = "left"
    		when "left"
    			@direction = "right"
    		when "up"
    			@direction = "down"
    		when "down"
    			@direction = "up"
    		when "No"
    			return

    moveStep: (direction) =>
	    bound = @arena.getBound()
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
	    bound = @arena.getBound()
	    if (x  > bound['x1'] and x < bound['x2'] and y  > bound['y1'] and y < bound['y2'])
	        @get().x = x
	        @get().y = y
	        @updateCoords()
	    else
	    	console.log('invalid coordinates: (' + x + ',' + y + ')')

	updateCoords: ->
	    @get().localToGlobal @x, @y
	    @x = @get().x
	    @y = @get().y

    getRect: ->
        x1 = @get().getBounds().x + @get().x
        y1 = @get().getBounds().y + @get().y
        x2 = @get().getBounds().x + @get().x + @get().getBounds().width
        y2 = @get().getBounds().y + @get().y + @get().getBounds().height
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    detectCollision: () ->
        object = @
        rect1 = @getRect()
        for otherObject in @arena.getObjects()
          if object.id == otherObject.id
             continue
          rect2 = otherObject.getRect()
          if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
            console.log(object.name + 'collide with' + otherObject.name)
            @collisionHandler object,otherObject

    updateSpeed: (a,b) ->
    	v1 = a.speed
    	v2 = b.speed
    	if a.direction == "No"
    		a.direction = b.direction
    		b.reverseDirection()
    	if b.direction == "No"
    		b.direction = a.direction
    		a.reverseDirection()
    	if a.direction != "No" and b.direction != "No"
    		a.reverseDirection()
    		b.reverseDirection()
    	a.speed = Math.abs(a.mass-b.mass)/(a.mass+b.mass)*v1
    	a.speed += (2*b.mass)/(a.mass + b.mass)*v2
    	b.speed = (2*b.mass)/(a.mass + b.mass)*v1
    	b.speed += Math.abs(a.mass-b.mass)/(a.mass+b.mass)*v2
    	# a.state = 'disabled'
    	# b.state = 'disabled'
    	a.get().addEventListener("tick", @collide);
    	b.get().addEventListener("tick", @collide);


	collisionHandler: (a,b)->
		#override in child class
		@updateSpeed a,b

	collide:(event) =>
		object = event.target
		switch @direction
			when "right"
				object.x += @speed
			when "left"
				object.x -= @speed
			when "up"
				object.y += @speed
			when "down"
				object.y -= @speed
		@updateCoords()
		@speed -= 1
		if @speed <= 0
			@speed = @originSpeed
			object.removeEventListener("tick", @collide)

    gotHit: (direction) ->
        console.log("nothing happened")