class window.Character
    constructor: (@name, @type, @speed, @x, @y, @stage,@arena) ->
        @id
        @type
        @hp = 100
        @spriteSheetInfo
        @character
        @characterSpriteSheet
        @direction = "right"
        @stage
        @arena
        @state = "idle"
        @init()


    init:() ->
        if @type == "robot"
            data = eval(robot_schema)
        else
            data = eval(player_schema)

        @spriteSheetInfo = data.spriteSheetInfo
        @magicSheetInfo = data.magicSheetInfo

        console.log 'init'
        @characterSpriteSheet = new createjs.SpriteSheet @spriteSheetInfo
        @character = new createjs.BitmapAnimation @characterSpriteSheet
        @character.x = @x
        @character.y = @y
        @character.gotoAndPlay "idle"

        @character.addEventListener "animationend", ((evt) ->
            if ((@state == 'idle') || (@state == 'hurt'))
                @idle()

        ).bind this


    addToStage: (stage) ->
        stage.addChild(@character)
        @stage = stage


    moveStep: (direction)->
        bound = @arena.getBound()
        switch direction
            when "left"
                if (@direction != "left")
                    @changeDirection "left"
                if(@character.x - @speed > bound['x1'])
                    @character.x -= @speed
                else
                    @character.x += @speed
            when "right"
                if (@direction != "right")
                    @changeDirection "right"
                if(@character.x + @speed < bound['x2'])
                    @character.x += @speed
                else
                    @character.x -= @speed
            when "down"
                if(@character.y + @speed < bound['y2'])
                    @character.y += @speed
                else
                    @character.y -= @speed
            when "up"
                if(@character.y - @speed > bound['y1'])
                    @character.y -= @speed
                else
                    @character.y += @speed

    run: (direction) ->
        if not @checkState()
            return
        if (@character.currentAnimation != "run")
            @character.gotoAndPlay "run"
        @state = "run"
        @moveStep(direction)
        @character.localToGlobal @x, @y
        @x = @character.x
        @y = @character.y


    attack: ->
        if @character.currentAnimation == "idle"
            @character.gotoAndPlay "attack"

    cast: ->
        if @character.currentAnimation == "idle"
            bound = @getRect()
            width = bound.x2-bound.x1
            x  = if (@direction == 'right') then @x+width  else @x-width
            m = new Magic @character, @magicSheetInfo, @direction, x, @y, @stage, @arena
            m.cast()

    getRect: ->
        x1 = @character.getBounds().x + @character.x
        y1 = @character.getBounds().y + @character.y
        x2 = @character.getBounds().x + @character.x + @character.getBounds().width
        y2 = @character.getBounds().y + @character.y + @character.getBounds().height
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    changeDirection: (direction) ->
            @direction = direction
            @character.scaleX = -@character.scaleX

    idle: ->
        @setState 'idle'
        if (@character.currentAnimation != "idle")
            @character.gotoAndPlay "idle"

    gotHit: (direction) ->
        if @checkState()
            @setState 'hurt'
        @character.gotoAndPlay "hurt"
        bound = @arena.getBound()
        @moveStep(direction)


    setState: (state) ->
        @state = state


    checkState: ->
        if @character.currentAnimation == "hurt"
            false
        else
            true

    getPlayer: ->
        return @character


