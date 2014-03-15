Object = require("./Object.js")

class Magic extends Object
    constructor: (@name,@type, @x, @y, @world, @character, @direction) ->
        super(@name,@type, @x, @y, @world)

    init:() ->
        @speed = @originSpeed
        @state = "run"


    collisionHandler: (o)->
        o.gotHit(@direction)
        console.log('hit player'+o.id)
        @state = "removed"



################################################################
module.exports = Magic