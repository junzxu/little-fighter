class window.Magic extends Object
    constructor: (@name,@type, @x, @y, @world, @character, @spriteSheetInfo, @direction) ->
        #dirction is its moving direction
        super
        @magic
        @damage = 10

    init:() ->
        @SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo
        @magic = new createjs.BitmapAnimation @SpriteSheet
        @magic.x = @x
        @magic.y = @y
        @collisionHeight = 0
        @collisionWidth = 0
        @speed = @originSpeed
        @world.addObject @
        @cast()

    cast:() ->
        console.log('cast magic on '+@direction)
        @magic.addEventListener("tick", @move);
        @world.get().addChild @magic
        @magic.gotoAndPlay "cast"


    move: (event)=>
        magic = event.target
        bound = @world.getBound()
        if @direction == "right"
            magic.x += @speed
        else 
            magic.x -= @speed
        @detectCollision false
        if magic.x > bound['x2'] or magic.x < 0
            @world.get().removeChild magic


    collisionHandler: (o)->
        dir = @counterDirection(@direction)
        o.gotHit(@damage, dir)
        console.log('hit player'+o.id)
        @get().removeAllEventListeners();
        @world.removeObject @


    get: ->
        return @magic