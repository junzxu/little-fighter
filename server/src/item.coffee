object = require("./object.js")

class Item extends object
    constructor: (@id, @name, @x, @y, @bound) ->
        super(@name, "item", @x, @y, @bound)
        @setupInfo(item_schema.info)
        @hp = @maxhp
        @faceDirection = "right"

    init:() ->
        super
        #should load schema from database
        path = "./items/" + @name + ".js"
        item_schema = require(path)

        @spriteSheetInfo = item_schema.spriteSheetInfo
        @gotHit = item_schema.gotHit
        if item_schema.collide
            @collide = item_schema.collide
        if item_schema.collisionHandler
            @collisionHandler = item_schema.collisionHandler


    move: (direction) ->
        if @checkState()
            @setState "run"
            @speed = @originSpeed
            @direction = direction
            @faceDirection = if direction in ["left","ul",'dl'] then "left" else "right" 
            @moveStep()
            return true
        return false


    idle: ->
        @state = 'idle'
        @speed = 0
        @direction = "No"


    gotHit: (damage,direction) ->



    collide: (direction) ->



    setState: (state, animation = null) ->
        @state = state
        if animation != null
            @animation = animation
        switch state
            when "idle"
                @idle()
            else
                setTimeout ( -> 
                    @idle()
                 ).bind(this), @animationTime()


    animationTime: (act = null) ->
        if act == null
            act = @state
        switch act
            when 'collided'
                return 100
            when 'hurt'
                return 100


    checkState: ->
        #["hurt","attack","disabled","collided"]
        if @state in ["collided","removed","hurt"]
            false
        else
            true

    getStatus: ->
        @info.x = @x
        @info.y = @y
        @info.state = @state
        @info.animation = @animation
        @info.direction = @direction
        @info.faceDirection = @faceDirection
        @info.hp = @hp
        return @info
################################################################
module.exports = Item
