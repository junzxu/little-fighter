class window.Object
	constructor: (@name, @type, @x, @y, @world) ->
        @id
        @type
        @hp
        @mass = 1
        @speed = 0  #current speed
        @originSpeed = 5
        @collisionHeight = 20
        @collisionWidth = 30
        @spriteSheetInfo
        @SpriteSheet
        @object = null
        @objectSpriteSheet
        @direction
        @world
        @magicState = "ready"
        @init()

    init:() ->
    	#load spriteSheet, do extra init in child class
    	if @spriteSheetInfo
    		@SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo

    get: ->
    	#override in child class
    	return @object

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

    getCollisionRect: ->
        x1 = @get().getBounds().x + @get().x + @collisionWidth
        y1 = @get().getBounds().y + @get().y + @collisionHeight
        x2 = @get().getBounds().x + @get().x + @get().getBounds().width - @collisionWidth
        y2 = @get().getBounds().y + @get().y + @get().getBounds().height - @collisionHeight
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    gotHit: (direction) ->
        console.log("nothing happened")


################################ Collision ###########################        
    detectCollision: () =>
        object = @
        rect1 = @getCollisionRect()
        for otherObject in @world.getObjects()
          if object.id == otherObject.id
             continue
          rect2 = otherObject.getCollisionRect()
          if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
            console.log(object.name + ' collide with ' + otherObject.name)
            @collisionHandler object,otherObject
        return [object,otherObject]

    collide: (a,b) =>
    	#default collide behavior
    	v1 = a.speed
    	v2 = b.speed
    	if a.direction != "No" and b.direction != "No"
    		a.reverseDirection()
    		b.reverseDirection()
    		b.moveStep(b.direction)
    	if a.direction == "No"
    		a.direction = b.direction
    		b.reverseDirection()
    		a.moveStep(a.direction)
    	if b.direction == "No"
    		b.direction = a.direction
    		a.reverseDirection()
    		b.moveStep(b.direction)
    	a.speed = Math.abs(a.mass-b.mass)/(a.mass+b.mass)*v1
    	a.speed += (2*b.mass)/(a.mass + b.mass)*v2
    	b.speed = (2*b.mass)/(a.mass + b.mass)*v1
    	b.speed += Math.abs(a.mass-b.mass)/(a.mass+b.mass)*v2
    	a.state = 'disabled'
    	b.state = 'disabled'
    	#we must pass exactly same function reference to remove Eventlistener
    	handlder_a = @updatePosition.bind a
    	handlder_b = @updatePosition.bind b
    	a.get().addEventListener "tick", handlder_a
    	b.get().addEventListener "tick", handlder_b
    	return [handlder_a,handlder_b]

	collisionHandler: (a,b) =>
        #override in child class
        handlders = @collide a,b
        createjs.Tween.get a, {loop:false} 
        .wait(200) 
        .call(
            (-> 
                a.idle()
                a.get().removeEventListener "tick", handlders[0]
            ))
        createjs.Tween.get b, {loop:false} 
        .wait(200) 
        .call(
            (-> 
                b.idle()
                b.get().removeEventListener "tick", handlders[1]
            ))

	updatePosition:(event) ->
		object = event.target
		switch @direction
			when "right"
				object.x += @speed
			when "left"
				object.x -= @speed
			when "up"
				object.y -= @speed
			when "down"
				object.y += @speed
		@updateCoords()
		if @speed <= 0
			@speed = @originSpeed

################################################################