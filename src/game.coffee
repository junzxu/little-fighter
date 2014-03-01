class window.Game
    constructor: ->
        @Y_AXIS_THREASHOLD = 30; # hit detection of y axis threashold in pixels

    init: ->
        @keysDown = {}
        @players = []

        @stageInit()
        @serverInit()

        createjs.Ticker.setFPS 60
        createjs.Ticker.addEventListener "tick", @stage
        @ready = false


        @lastKeyPress = new Date()


        @addEventHandlers()


    # Server setup
    serverInit: () ->
        @socket = io.connect "http://localhost", {port: 8000, transports: ["websocket"]}
        console.log @socket


    # Stage setup
    stageInit: () ->
        @rect = new createjs.Rectangle 0, 0, 100, 100
        # Setup Stage
        @stage = new createjs.Stage document.getElementById("gameCanvas")
        @arena = new Arena @stage.canvas.width, @stage.canvas.height, @players
        @arena.setPosition 0, 0
        @arena.addToStage @stage
        #add a ai robot
        robot = new Character "firzen", "robot", 400, 200, @stage, @arena
        robot.id = 0
        @arena.addPlayer robot


    addEventHandlers: () ->

        @socket.on "connect", @onConnected.bind this
        @socket.on "new player", @onNewPlayer.bind this
        @socket.on "client id", @onReceivedClientID.bind this
        @socket.on "update", @onUpdate.bind this
        @socket.on "disconnect", @onDisconnect.bind this
        createjs.Ticker.addEventListener "tick", @onTick.bind this


    # Handlers for events
    onUpdate: (data) ->
        if (data.id != @clientID)
                console.log 'update'
                updatePlayer = @playerGet (data.id)

                updatePlayer.x = data.x
                updatePlayer.y = data.y
                updatePlayer.run data.dir
        if (data.state)
            if (data.state == "idle")
                #updatePlayer.idle()
                console.log 'IDLEEEEEEEE'

    # Connected to Server
    onConnected: () ->

    # Received client ID from the server
    onReceivedClientID: (data) ->
        # Send local player to server
        @socket.emit "new player", {id:data.id,x:250, y:250}

        @clientID = data.id

    # New player has joined ( This include the local)
    onNewPlayer: (data) ->
        if !(@playerExists data.id)
            console.log 'Add new player to stage ' + data.id
            player = new Character "firzen", "player", data.x, data.y, @stage, @arena
            player.id = data.id
            @arena.addPlayer player

        if (data.id == @clientID)
            @localPlayer = player
            createjs.Ticker.addEventListener "tick", ((evt) ->
            ).bind this


            window.addEventListener "keydown", ((e) ->
                @keysDown[e.keyCode] = true
            ).bind this

            window.addEventListener "keyup", ((e) ->
                @keysDown[e.keyCode] = false
                if (!@keysDown[Constant.KEYCODE_RIGHT] && !@keysDown[Constant.KEYCODE_LEFT] && !@keysDown[Constant.KEYCODE_UP] && !@keysDown[Constant.KEYCODE_DOWN])
                    if (player.character.currentAnimation == "run")
                        player.idle()
                    player.setState 'idle'
                    @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, state:"idle"}
            ).bind this

        else

    onDisconnect: (data) ->
        console.log 'Player: ' + data.id + ' has disconnected';

    # This event is trigged every frame
    onTick: (e) ->

        # Check which key is been pressed
        if (@keysDown[Constant.KEYCODE_RIGHT])
            @localPlayer.run 'right'
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"right"}

        if (@keysDown[Constant.KEYCODE_LEFT])
            @localPlayer.run 'left'
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"left"}

        if (@keysDown[Constant.KEYCODE_DOWN])
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"down"}
            @localPlayer.run 'down'

        if (@keysDown[Constant.KEYCODE_UP])
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"up"}
            @localPlayer.run 'up'

        if (@keysDown[Constant.KEYCODE_J])
            @localPlayer.attack()
            @socket.emit "attack", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y}

        if (@keysDown[Constant.KEYCODE_K])
            @localPlayer.cast()
            @socket.emit "magic", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y}


    onKeyDown: (e) ->
        console.log "key down " + e.keyCode
        @keysDown[e.keyCode] = true

    onKeyUp: (e) ->
        console.log "key up " + e.keyCode
        @keysDown[e.keyCode] = false


    # Member Functions #############################################################################
    playerExists: (id) ->
        for p in @players
            if (p.id == id)
                return true
        return false

    playerGet: (id) ->
        for p in @players
            if (p.id == id)
                return p

    # Check if 2 rectangles intersect
    collide: (rect1, rect2) ->
        console.log 'rect1 ' + rect1.y2
        console.log 'rect2 ' + rect2.y2
        console.log (!(rect2.x2 < rect1.x1) && !(rect2.x1 > rect1.x2))
        console.log  (rect1.y2 - @Y_AXIS_THREASHOLD)
        console.log (rect1.y2 + @Y_AXIS_THREASHOLD)
        return (!(rect2.x2 < rect1.x1) && !(rect2.x1 > rect1.x2) && (rect2.y2 > (rect1.y2 - @Y_AXIS_THREASHOLD)) && (rect2.y2 < (rect1.y2 + @Y_AXIS_THREASHOLD)))

