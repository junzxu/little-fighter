class object
	constructor: (@name, @type, @x, @y, @world) ->
        @id
        @type
        @hp
        @mass = 1
        @speed = 0  #current speed
        @originSpeed = 2
        @collisionHeight = 20
        @collisionWidth = 30
        @spriteSheetInfo
        @magicState = "ready"
        @init()

    init:() ->
    	#load spriteSheet, do extra init in child class
        @state = "idle"
        @direction = "No"
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
            when "ur"
                return "dl"
            when "ul"
                return "dr"
            when "dr"
                return "ul"
            when "dl"
                return "ur"
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
                @direction = "left"
                if(@x - speed > bound['x1'])
                    @x -= speed
                else
                    @x += speed
            when "right"
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
            when "ur"
                @direction = "ur"
                if(@y - speed > bound['y1'])
                    @y -= speed
                if(@x + speed < bound['x2'])
                    @x += speed
            when "ul"
                @direction = "ul"
                if(@y - speed > bound['y1'])
                    @y -= speed
                if( @x - speed > bound['x1'])
                    @x -= speed
            when "dr"
                @direction = "dr"
                if(@y + speed < bound['y2'])
                    @y += speed
                if(@x + speed < bound['x2'])
                    @x += speed
            when "dl"
                @direction = "dl"
                if(@y + speed < bound['y2'])
                    @y += speed
                if(@x - speed > bound['x1'])
                    @x -= speed

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
        if object.x < @x
            return "left"
        if object.x >= @x
            return "right"

################################ Collision ###########################        
    collide: (direction) ->
        #default collide behavior
        if @direction == "No"
           @direction = direction
           @moveStep(direction,10)
        else
            @reverseDirection()
            @moveStep()
        @speed = 2
        @setState 'collided'

    collisionHandler: (object, direction) ->
        #override in child class, direction argument is for still objects
        @collide direction
        if object.state != "collided"
            object.collisionHandler @, @counterDirection(direction)


############################# helper function ##########################

    distanceTo:(object) ->
        if object == null
            return Infinity
        squared = Math.pow((@.x - object.x),2) + Math.pow((@y - object.y),2)
        d = Math.sqrt(squared)
        return d

    inRange:(bound) ->
        #check if object's position is inside a given range
        rect = @getRect
        if !((rect.x2 < bound.x1) || (rect.x1 > bound.x2 ) || (rect.y1 > bound.y2 ) || (rect.y2 < bound.y1))
            return true
        else
            return false

################################################################
module.exports = object