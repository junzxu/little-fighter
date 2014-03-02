class window.Character extends Object
    constructor: (@name, @type, @x, @y, @world) ->
        super
        @hp = 100
        @cd = 300
        @character
        @faceDirection = "right"

    init:() ->
        super
        #should load schema from database
        @state = "idle"
        @direction = "No"
        if @type == "robot"
            data = eval(robot_schema)
        else
            data = eval(player_schema)

        @spriteSheetInfo = data.spriteSheetInfo
        @magicSheetInfo = data.magicSheetInfo

        console.log 'init'
        @SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo
        @character = new createjs.BitmapAnimation @SpriteSheet
        @character.x = @x
        @character.y = @y
        @character.gotoAndPlay "idle"

        @character.addEventListener "animationend", ((evt) ->
            switch @state
                when 'die'
                    @setState 'idle'
                    @rebirth()
                    break
                when 'disabled'
                    break
                else
                    @idle()
        ).bind this


    addToWorld: (world) ->
        world.addPlayer @
        @world = world

    get: ->
        return @character

    changeFaceDirection: (direction) ->
        if @faceDirection == direction
            return
        else
            @faceDirection = direction
            @get().scaleX = -@get().scaleX

    run: (direction) ->
        if not @checkState()
            return
        if (@character.currentAnimation != "run")
            @character.gotoAndPlay "run"
        @setState "run"
        @speed = @originSpeed
        @moveStep(direction)
        if direction in ["left","right"]
            @changeFaceDirection(direction)
        @detectCollision()


    attack: ->
        if @checkState()
            @character.gotoAndPlay "attack"

    cast: ->
        if @checkState() and @magicState == 'ready'
            bound = @getRect()
            width = bound.x2-bound.x1
            x  = if (@faceDirection == 'right') then @x+width  else @x-width
            m = new Magic 'blue','magic', x, @y, @world, @character, @magicSheetInfo, @faceDirection
            m.cast()
            @magicState = 'preparing'
            createjs.Tween.get @character, {loop:false} 
            .wait(@cd) 
            .call(
                (=> 
                    @magicState = "ready"
                ))

    rebirth: ->
        @world.get().removeChild @character
        bound = @world.getBound()
        x = Math.floor(Math.random() * bound.x2)
        y = Math.floor(Math.random() * bound.y2)
        @character.x = x
        @character.y = y
        @updateCoords()
        @hp = 100
        createjs.Tween.get @character, {loop:false} 
        .wait(3000) 
        .call(
            (=> 
                @world.get().addChild @character
                @character.gotoAndPlay "idle")
            )


    idle: ->
        @setState 'idle'
        @speed = 0
        @direction = "No"
        if (@character.currentAnimation != "idle")
            @character.gotoAndPlay "idle"

    gotHit: (direction,damage = 10) ->
        console.log('current hp: ' + @hp)
        @hp -= damage
        if @hp <= 0
            @character.gotoAndPlay "die"
            @setState 'die'
        else
            @setState 'hurt'
            @changeFaceDirection @counterDirection(direction)
            @character.gotoAndPlay "hurt"
            bound = @world.getBound()
            @moveStep(direction)


    setState: (state) ->
        @state = state


    checkState: ->
        if @state == "disabled" or @character.currentAnimation in ["hurt","attack"]
            false
        else
            true



