    var
    gameport = process.env.PORT || 3000,

        io = require('socket.io'),
        express = require('express'),
        url = require('url'),
        UUID = require('node-uuid'),
        Server = require('./server/js/game_server.js')
        http = require('http'),
        app = express(),
        server = http.createServer(app);

    /* Express server set up. */

    //The express server handles passing our content to the browser,
    //As well as routing users where they need to go. This example is bare bones
    //and will serve any file the user requests from the root of your web server (where you launch the script from)
    //so keep this in mind - this is not a production script but a development teaching tool.

    app.use("/css", express.static(__dirname + '/css'));
    app.use("/lib", express.static(__dirname + '/lib'));
    app.use("/js", express.static(__dirname + '/js'));
    app.use("/assets", express.static(__dirname + '/assets'));
    //Tell the server to listen for incoming connections
    server.listen(gameport)

    //Log something so we know that it succeeded.
    console.log('\t :: Express :: Listening on port ' + gameport);

    //By default, we forward the / path to index.html automatically.
    app.get('/', function(req, res) {
        console.log('trying to load %s', __dirname + '/index.html');
        res.sendfile('/index.html', {
            root: __dirname
        });
    });

    app.get('/*', function(req, res) {
        if (req.query.id) {
            var id = req.params.id;
            console.log('trying to load %s', __dirname + '/index.html');
            res.sendfile('/index.html', {
                root: __dirname
            });
        } else {
            res.status(404).send('Not found');
        }
    });



    /* Socket.IO server set up. */

    //Express and socket.io can work together to serve the socket.io client files for you.
    //This way, when the client requests '/socket.io/' files, socket.io determines what the client needs.

    //Create a socket.io instance using our express server
    var sio = io.listen(server);

    //Configure the socket.io connection settings.
    //See http://socket.io/
    sio.configure(function() {

        sio.set('log level', 0);

        sio.set('authorization', function(handshake, callback) {
            // var url_parts = url.parse(handshake.url, true);
            // var query = url_parts.query;
            console.log('Auth: ', handshake.query);
            if (handshake.query.id != null) {
                // id = handshake.url.slice(1);
                // id = query.id
                handshake.gameid = handshake.query.id;
            } else {
                handshake.gameid = UUID();
            }
            callback(null, true); // error first callback style
        });

    });

    //Enter the game server code. The game server handles
    //client connections looking for a game, creating games,
    //leaving games, joining games and ending games when they leave.
    var game_server = new Server(sio);

    //Socket.io will call this function when a client connects,
    //So we can send that client looking for a game to play,
    //as well as give that client a unique ID to use so we can
    //maintain the list if players.
    sio.sockets.on('connection', function(client) {
        //Generate a new UUID, looks something like
        //5b2ca132-64bd-4513-99da-90e838ca47d1
        //and store this on their socket/connection
        client.userid = UUID();
        client.gameid = client.handshake.gameid;
        client.join(client.gameid);
        game_server.clients.push(client);
        //tell the player they connected, giving them their id
        client.emit('connected', {
            id: client.userid,
            gameid: client.gameid
        });

        //Useful to know when someone connects
        console.log('\t socket.io:: player ' + client.userid + ' connected');

        //now we can find them a game to play with someone.
        //if no game exists with someone waiting, they create one and wait.
        game_server.findGame(client);

        console.log('\t socket.io:: found a game for player ' + client.userid);
        //Now we want to handle some of the messages that clients will send.
        //They send messages here, and we send them to the game_server to handle.
        client.on('update', function(message) {

            game_server.onUpdate(client, message);

        }); //client.on message

        //When this client disconnects, we want to tell the game server
        //about that as well, so it can remove them from the game they are
        //in, and make sure the other player knows that they left and so on.
        client.on('disconnect', function() {

            //Useful to know when soomeone disconnects
            // console.log('\t socket.io:: client disconnected ' + client.userid + ' ' + client.gameid);

            //all players leaving a game should destroy that game
            game_server.endGame(client.gameid, client.userid);
            game_server.removeClient(client)
            client.leave(client.gameid)

        }); //client.on disconnect

    }); //sio.sockets.on connection