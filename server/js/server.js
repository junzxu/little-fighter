// Generated by CoffeeScript 1.7.1
(function() {
  var Server, gameServer;

  Server = (function() {
    function Server() {
      this.util = require("util");
      this.express(require("express"));
      this.io = require("socket.io");
      this.Character = require("../js/character.js").Character;
      this.players = [];
      this.init();
    }

    Server.prototype.init = function() {
      this.socket = this.io.listen(8000);
      this.socket.configure(function() {
        this.set("transports", ["websocket"]);
        return this.set("log level", 2);
      });
      return this.setEventHandlers();
    };

    Server.prototype.removePlayer = function(id) {
      var key, p, _i, _len, _ref, _results;
      _ref = this.players;
      _results = [];
      for (p = _i = 0, _len = _ref.length; _i < _len; p = ++_i) {
        key = _ref[p];
        if (p.id === id) {
          _results.push(this.players.splice(key, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Server.prototype.setEventHandlers = function() {
      return this.socket.sockets.on("connection", this.onSocketConnection.bind(this));
    };

    Server.prototype.onSocketConnection = function(client) {
      var player, _i, _len, _ref, _results;
      this.util.log(client.id);
      client.emit("client id", {
        id: client.id
      });
      client.on("new player", this.onNewPlayer.bind(this));
      client.on("disconnect", this.onSocketDisconnect.bind(this));
      client.on("update", this.onSocketUpdate.bind(this));
      client.on("attack", this.onPlayerAttack.bind(this));
      _ref = this.players;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        player = _ref[_i];
        client.emit("new player", {
          id: player.id,
          x: player.x,
          y: player.y
        });
        _results.push(this.util.log('emitting existing player:' + player.id));
      }
      return _results;
    };

    Server.prototype.onPlayerAttack = function(data) {
      var player, _i, _len, _ref, _results;
      this.util.log('attacking ' + data.id + 'at position: ' + data.x + ',' + data.y);
      _ref = this.players;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        player = _ref[_i];
        if (player.id !== data.id) {
          _results.push(this.util.log('got hit'));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Server.prototype.onSocketDisconnect = function(client) {
      this.util.log('client ' + this.id + ' has disconnected');
      this.removePlayer(client.id);
      return this.socket.sockets.emit("disconnect", {});
    };

    Server.prototype.onNewPlayer = function(data) {
      this.util.log('New Player:' + data.id + '--- Location:' + data.x + ',' + data.y);
      this.players.push({
        id: data.id,
        x: data.x,
        y: data.y,
        hp: 100
      });
      return this.socket.sockets.emit("new player", {
        id: data.id,
        x: data.x,
        y: data.y
      });
    };

    Server.prototype.onSocketUpdate = function(data) {
      this.util.log("update: id:" + data.id + " x:" + data.x + " y:" + data.y);
      return this.socket.sockets.emit("update", {
        id: data.id,
        x: data.x,
        y: data.y,
        dir: data.dir,
        state: data.state
      });
    };

    return Server;

  })();

  gameServer = new Server;

}).call(this);
