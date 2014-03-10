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



    realtiveDirection: (object) ->
        #target object's direction relative to this object
        if object.get().x < @get().x
            return "left"
        if object.get().x >= @get().x
            return "right"

################################ Collision ###########################        
    detectCollision: (trigger = true)->
        object = @
        rect1 = @getCollisionRect()
        for otherObject in @world.getObjects()
          if @id == otherObject.id
             continue
          rect2 = otherObject.getCollisionRect()
          if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
            # console.log(object.name + ' collide with ' + otherObject.name)
            d1 = otherObject.direction
            d2 = @direction
            @collisionHandler otherObject, d1
            if trigger
                otherObject.collisionHandler @, d2
            return [object,otherObject]
          else
            return []

    collide: (o,direction) ->
    	#default collide behavior
    	console.log(@.name + ' collide with ' + o.name)
    	v1 = @speed
    	v2 = o.speed
    	if @direction == "No"
    		@direction = direction
    		@moveStep(direction)
    	else
    		@reverseDirection()
    		@moveStep(@direction)
    	@speed = Math.abs(@mass-o.mass)/(@mass+o.mass)*v1
    	@speed += (2*o.mass)/(@mass + o.mass)*v2
    	@state = 'disabled'
    	#we must pass exactly same function reference to remove Eventlistener
    	handlder = @updatePosition.bind this
    	@get().addEventListener "tick", handlder
    	return handlder

	collisionHandler: (o,direction = 'No') ->
        #override in child class, direction argument is for still objects
        handlder = @collide o,direction
        createjs.Tween.get @, {loop:false} 
        .wait(100) 
        .call(
            (-> 
                @idle()
                @get().removeEventListener "tick", handlder
            ))

	updatePosition:(event) ->
		object = event.target
		switch @direction
			when "right"
				object.x += 2
			when "left"
				object.x -= 2
			when "up"
				object.y -= 2
			when "down"
				object.y += 2
		@updateCoords()

################################################################