object = require("./object.js")

class Magic extends object
    constructor: (@id, @info, @x, @y, @characterID, @direction) ->
        super(@info.name, 'magic', @x, @y, null)
        @info.characterID = @characterID

    init:() ->
        #load spritesheet info from db
        @setupInfo(@info)
        @speed = @originSpeed
        @collisionHeight = 0
        @collisionWidth = 0
        @setState "run"


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


    setState: (state, animation = null) ->
        @state = state
        if animation != null
            @animation = animation
        else
            @animation = state

    getStatus: ->
        @info.x = @x
        @info.y = @y
        @info.state = @state
        @info.animation = @animation
        @info.direction = @direction
        return @info

################################################################
module.exports = Magic