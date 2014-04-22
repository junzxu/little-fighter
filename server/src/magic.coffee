object = require("./object.js")

class Magic extends object
    constructor: (@id, @info, @x, @y, @world, @characterID, @direction) ->
        super(@info.name, 'magic', @x, @y, @world)

    init:() ->
        #load spritesheet info from db
        @originSpeed = @info.originSpeed
        @speed = @originSpeed
        @damage = @info.damage
        @collisionHeight = 0
        @collisionWidth = 0
        @width = @info.width
        @height = @info.height
        @setState "run"
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
        @info.characterID = @characterID
        return @info

################################################################
module.exports = Magic