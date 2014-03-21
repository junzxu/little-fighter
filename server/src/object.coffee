class object
	constructor: (@name, @type, @x, @y, @world) ->
        @id
        @type
        @hp
        @state = "idle"
        @mass = 1
        @speed = 0  #current speed
        @originSpeed = 2
        @collisionHeight = 20
        @collisionWidth = 30
        @spriteSheetInfo
        @direction
        @magicState = "ready"
        @init()

    init:() ->
    	#load spriteSheet, do extra init in child class
        @width
        @height 


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


    moveStep: (direction = null, speed = null) =>
        bound = @world.getBound()
        if direction == null
            direction = @direction
        if speed == null
            speed = @speed
        switch direction
            when "left"
                if (@direction != "left")
                    @direction = "left"
                if(@x - speed > bound['x1'])
                    @x -= speed
                else
                    @x += speed
            when "right"
                if (@direction != "right")
                    @direction = "right"
                if(@x + speed < bound['x2'])
                    @x += speed
                else
                    @x -= speed
            when "down"
                @direction = "down"
                if(@y + speed < bound['y2'])
                    @y += speed
                else
                    @y -= speed
            when "up"
                @direction = "up"
                if(@y - speed > bound['y1'])
                    @y -= speed
                else
                    @y += speed

	moveTo: (x,y)->
        bound = @world.getBound()
        if (x  > bound['x1'] and x < bound['x2'] and y  > bound['y1'] and y < bound['y2'])
            @x = x
            @y = y
        else
            console.log('invalid coordinates: (' + x + ',' + y + ')')


    getRect: ->
        x1 = @x - @width/2
        y1 = @y - @height/2
        x2 = @x + @width/2
        y2 = @y + @height/2
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    getCollisionRect: ->
        x1 = @x - @width/2 + @collisionWidth
        y1 = @y - @height/2 + @collisionHeight
        x2 = @x + @width/2 - @collisionWidth
        y2 = @y + @height/2 - @collisionHeight
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}


    gotHit: (direction) ->
        console.log("got hit")


    realtiveDirection: (object) ->
        #target object's direction relative to this object
        if object.x < @get().x
            return "left"
        if object.x >= @get().x
            return "right"

################################ Collision ###########################        
    collide: (o) ->
        #default collide behavior
        console.log(@name + ' collide with ' + o.name)
        v1 = @speed
        v2 = o.speed
        if o.direction == "No"
           o.direction = @direction
           o.moveStep(direction)
        else
            o.reverseDirection()
            o.moveStep()
        o.speed = Math.abs(o.mass-@mass)/(@mass+o.mass)*v1
        o.speed += (2*@mass)/(@mass + o.mass)*v2
        o.state = 'collided'
        @state = 'collided'

	collisionHandler: (object) ->
        #override in child class, direction argument is for still objects
        @collide object
        setTimeout ( => 
            if @state == "collided"
                @state = "idle"
            if object.state == "collided"
                object.state = "idle"
         ).bind(this), 100



################################################################
module.exports = object