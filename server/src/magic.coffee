object = require("./object.js")
player_schema = require("./player_schema.js")

class Magic extends object
    constructor: (@id, @name, @x, @y, @world, @characterID, @direction) ->
        super(@name, 'magic', @x, @y, @world)

    init:() ->
        #load spritesheet info from db
        @originSpeed = 5
        @speed = @originSpeed
        @damage = 10
        @collisionHeight = 0
        @collisionWidth = 0
        @width = 126
        @height = 55
        @state = "run"
        @info = {'id':@id, 'name':@name, 'type':@type,'width':@width,'height':@height, 'originSpeed':@originSpeed } 


    collisionHandler: (o)->
        if o.id != @characterID
            o.gotHit(@damage, @counterDirection(@direction))
            @state = "removed"


    moveStep: (direction = null, speed = null) =>
        #overide the default move function because magic can go out of bound
        if direction == null
            direction = @direction
        if speed == null
            speed = @speed
        switch direction
            when "left"
                @x -= speed
            when "right"
                @x += speed
            when "down"
                @y += speed
            when "up"
                @y -= speed

    getStatus: ->
        @info.x = @x
        @info.y = @y
        @info.state = @state
        @info.direction = @direction
        @info.characterID = @characterID
        return @info

################################################################
module.exports = Magic