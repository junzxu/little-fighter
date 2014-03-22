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
        @width = 40
        @height = 40
        @state = "run"
        @magicSheetInfo = player_schema.magicSheetInfo


    collisionHandler: (o)->
        if o.id != @characterID
            o.gotHit(@damage, @direction)
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

################################################################
module.exports = Magic