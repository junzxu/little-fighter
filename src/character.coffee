class window.Character extends Object
    constructor: (@name, @type, @x, @y, @stage, @arena) ->
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
                when 'hurt'
                    @idle()
                else
                    @idle()
        ).bind this


    addToStage: (stage) ->
        stage.addChild(@character)
        @stage = stage

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
        if @character.currentAnimation == "idle"
            @character.gotoAndPlay "attack"

    cast: ->
        if @character.currentAnimation == "idle" and @magicState == 'ready'
            bound = @getRect()
            width = bound.x2-bound.x1
            x  = if (@faceDirection == 'right') then @x+width  else @x-width
            m = new Magic 'blue','magic', x, @y, @stage, @arena,@character, @magicSheetInfo, @faceDirection
            m.cast()
            @magicState = 'preparing'
            createjs.Tween.get @character, {loop:false} 
            .wait(@cd) 
            .call(
                (=> 
                    @magicState = "ready"
                ))

    rebirth: ->
        @arena.container.removeChild @character
        bound = @arena.getBound()
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
                @arena.container.addChild @character
                @character.gotoAndPlay "idle")
            )


    idle: ->
        @setState 'idle'
        @speed = 0
        # @direction = "No"
        if (@character.currentAnimation != "idle")
            @character.gotoAndPlay "idle"

    gotHit: (direction) ->
        console.log('current hp: ' + @hp)
        @hp -= 10
        if @hp <= 0
            @character.gotoAndPlay "die"
            @setState 'die'
        else
            @setState 'hurt'
            @character.gotoAndPlay "hurt"
            bound = @arena.getBound()
            @moveStep(direction)


    setState: (state) ->
        @state = state


    checkState: ->
        if @character.currentAnimation in ["hurt","attack","disabled"]
            false
        else
            true



