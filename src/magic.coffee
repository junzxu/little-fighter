class window.Magic extends object
    constructor: (@id, @name, @x, @y, @world, @characterID, @direction, @spriteSheetInfo) ->
        super(@id, @name, "magic" , @x, @y, @world)
        @magic
        @damage = 10
        @init()

    init:() ->
        @SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo
        @magic = new createjs.BitmapAnimation @SpriteSheet
        @magic.x = @x
        @magic.y = @y
        @magic.name = @name
        @collisionHeight = 0
        @collisionWidth = 0
        @originSpeed = 5
        @speed = @originSpeed
        @cast()

    cast:() ->
        if @direction == "left"
            @get().scaleX = -@get().scaleX
        @world.addObject @
        @magic.gotoAndPlay "cast"


    get: ->
        return @magic