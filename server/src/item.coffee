object = require("./object.js")
item_schema = require("./items/rock.js")

class Item extends object
    constructor: (@id, @name, @x, @y, @bound) ->
        super(@name, "item", @x, @y, @bound)
        @setupInfo(item_schema.info)
        @hp = @maxhp
        @faceDirection = "right"

    init:() ->
        super
        #should load schema from database
        @spriteSheetInfo = item_schema.spriteSheetInfo


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
        #direction indicates where the hit come from
        if @state == "removed"
            return
        @hp -= damage
        if @hp <= 0
            @setState 'removed'
        else
            @setState 'hurt'
            @faceDirection = direction
            @moveStep(@counterDirection(direction))


    collide: (direction) ->
        #override default collide behavior
        if @direction == "No"
           @direction = direction
        else
            @reverseDirection()
            @moveStep()
        @speed = 0.5
        @setState 'collided'


    setState: (state, animation = null) ->
        @state = state
        if animation != null
            @animation = animation
        switch state
            when "idle"
                @idle()
            when "collided"
                setTimeout ( -> 
                    @idle()
                 ).bind(this), @animationTime()


    animationTime: (act = null) ->
        if act == null
            act = @state
        switch act
            when 'collided'
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
