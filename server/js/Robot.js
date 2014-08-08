// Generated by CoffeeScript 1.7.1
(function() {
  var Robot, magic_schema, object, robot_schema,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  object = require("./object.js");

  robot_schema = require("./characters/julian.js");

  magic_schema = require("./magics/death.js");

  Robot = (function(_super) {
    __extends(Robot, _super);

    function Robot(id, name, type, x, y, bound) {
      this.id = id;
      this.name = name;
      this.type = type;
      this.x = x;
      this.y = y;
      this.bound = bound;
      this.moveTo = __bind(this.moveTo, this);
      Robot.__super__.constructor.call(this, this.name, this.type, this.x, this.y, this.bound);
      this.setupInfo(robot_schema.info);
      this.hp = this.maxhp;
      this.score = 0;
      this.number;
      this.username = "robot";
      this.faceDirection = "left";
      this.currentDestination = [this.x, this.y];
      this.waitTime = 0;
      this.oldtime = new Date().getTime();
    }

    Robot.prototype.init = function() {
      Robot.__super__.init.apply(this, arguments);
      this.spriteSheetInfo = robot_schema.spriteSheetInfo;
      this.magicSheetInfo = magic_schema.magicSheetInfo;
      this.magicInfo = magic_schema.info;
      return this.cd = this.magicInfo.cd;
    };

    Robot.prototype.move = function(direction) {
      if (this.checkState()) {
        this.setState("run");
        this.speed = this.originSpeed;
        this.direction = direction;
        this.faceDirection = direction === "left" || direction === "ul" || direction === 'dl' ? "left" : "right";
        this.moveStep();
        return true;
      }
      return false;
    };

    Robot.prototype.attack = function(target) {
      var dir;
      if (target == null) {
        target = null;
      }
      if (this.checkState()) {
        this.setState("attack");
        if (this.distanceTo(target) < this.attackRange) {
          dir = this.counterDirection(this.faceDirection);
          target.gotHit(this.damage, dir);
        }
        return true;
      }
      return false;
    };

    Robot.prototype.cast = function() {
      if (this.checkState() && this.magicState === 'ready') {
        this.magicState = 'preparing';
        if (this.state !== "cast") {
          this.setState("cast");
        }
        setTimeout(((function(_this) {
          return function() {
            return _this.magicState = "ready";
          };
        })(this)), this.cd);
        return true;
      }
      return false;
    };

    Robot.prototype.teleport = function(x, y) {
      this.state === "disabled";
      return setTimeout(((function(_this) {
        return function() {
          _this.x = x;
          _this.y = y;
          return _this.idle();
        };
      })(this)).bind(this), this.animationTime("teleport"));
    };

    Robot.prototype.rebirth = function() {
      if (this.state !== "die") {
        return;
      }
      this.idle();
      this.x = this.bound.x1 + Math.floor(Math.random() * (this.bound.x2 - this.bound.x1 - this.width));
      this.y = this.bound.y1 + Math.floor(Math.random() * (this.bound.y2 - this.bound.y1 - this.height));
      return this.hp = this.maxhp;
    };

    Robot.prototype.idle = function() {
      this.state = 'idle';
      this.speed = 0;
      return this.direction = "No";
    };

    Robot.prototype.gotHit = function(damage, direction) {
      if (this.state === "die") {
        return;
      }
      this.hp -= damage;
      if (this.hp <= 0) {
        this.setState('die');
        return this.score -= 30;
      } else {
        this.setState('hurt');
        this.faceDirection = direction;
        return this.moveStep(this.counterDirection(direction));
      }
    };

    Robot.prototype.setState = function(state, animation) {
      if (animation == null) {
        animation = null;
      }
      this.state = state;
      if (animation !== null) {
        this.animation = animation;
      } else {
        if (state !== "idle" && state !== "run") {
          this.animation = state;
        }
      }
      switch (state) {
        case "idle":
          return idle();
        case "run":
          break;
        case "die":
          return setTimeout(((function(_this) {
            return function() {
              return _this.rebirth();
            };
          })(this)).bind(this), this.animationTime("die"));
        default:
          return setTimeout((function() {
            if (this.hp > 0) {
              return this.idle();
            }
          }).bind(this), this.animationTime());
      }
    };

    Robot.prototype.checkState = function() {
      var _ref;
      if ((_ref = this.state) === "disabled" || _ref === "collided" || _ref === "die" || _ref === "hurt" || _ref === "attack") {
        return false;
      } else {
        return true;
      }
    };

    Robot.prototype.animationTime = function(act) {
      if (act == null) {
        act = null;
      }
      if (act === null) {
        act = this.state;
      }
      switch (act) {
        case 'hurt':
          return 800;
        case 'attack':
          return 1000;
        case 'cast':
          return 1100;
        case 'die':
          return 3000;
        case 'collided':
          return 100;
        case 'teleport':
          return 500;
        default:
          return null;
      }
    };

    Robot.prototype.collisionHandler = function(object, direction) {
      if (object.name !== "coin") {
        this.collide(direction);
      }
      if (object.state !== "collided") {
        return object.collisionHandler(this, this.counterDirection(direction));
      }
    };

    Robot.prototype.getStatus = function() {
      this.info.x = this.x;
      this.info.y = this.y;
      this.info.state = this.state;
      this.info.animation = this.animation;
      this.info.direction = this.direction;
      this.info.faceDirection = this.faceDirection;
      this.info.hp = this.hp;
      this.info.cd = this.cd;
      this.info.score = this.score;
      return this.info;
    };

    Robot.prototype.moveTo = function(dest) {
      var count, _ref;
      this.currentDestination = dest;
      count = 0;
      if (this.x < dest[0]) {
        count += 1;
      }
      if (this.x > dest[0]) {
        count += 2;
      }
      if (this.y < dest[1]) {
        count += 4;
      }
      if (this.y > dest[1]) {
        count += 8;
      }
      switch (count) {
        case 1:
          this.direction = 'right';
          break;
        case 2:
          this.direction = 'left';
          break;
        case 4:
          this.direction = 'down';
          break;
        case 8:
          this.direction = 'up';
          break;
        case 5:
          this.direction = 'dr';
          break;
        case 6:
          this.direction = 'dl';
          break;
        case 9:
          this.direction = 'ur';
          break;
        case 10:
          this.direction = 'ul';
      }
      this.setState('run');
      this.speed = this.originSpeed;
      return this.faceDirection = (_ref = this.direction) === "left" || _ref === "ul" || _ref === 'dl' ? "left" : "right";
    };

    Robot.prototype.wait = function(time) {
      this.idle();
      this.waitTime = time;
      return this.oldtime = new Date().getTime();
    };

    Robot.prototype.randomWalk = function() {
      var time, x, y;
      time = new Date().getTime();
      if (this.state === "idle" && time - this.oldtime < this.waitTime) {
        return;
      }
      if (!(Math.abs(this.x - this.currentDestination[0]) <= this.originSpeed && Math.abs(this.y - this.currentDestination[1]) <= this.originSpeed)) {
        return this.moveTo(this.currentDestination);
      } else {
        x = this.bound.x1 + Math.floor(Math.random() * (this.bound.x2 - this.bound.x1 - this.width));
        y = this.bound.y1 + Math.floor(Math.random() * (this.bound.y2 - this.bound.y1 - this.height));
        this.currentDestination = [x, y];
        return this.wait(2000);
      }
    };

    Robot.prototype.enemyInRange = function(players) {
      var d, distance, player, sightRange, target, _i, _len;
      if (this.faceDirection === "right") {
        sightRange = {
          "x1": this.x,
          "x2": this.x + this.sightRange,
          "y1": this.y - this.sightRange / 2,
          "y2": this.y + this.sightRange / 2
        };
      } else {
        sightRange = {
          "x1": this.x - this.sightRange,
          "x2": this.x,
          "y1": this.y - this.sightRange / 2,
          "y2": this.y + this.sightRange / 2
        };
      }
      target = null;
      distance = Infinity;
      for (_i = 0, _len = players.length; _i < _len; _i++) {
        player = players[_i];
        if (player.id === this.id || player.animation === "invisible") {
          continue;
        }
        if (player.inRange(sightRange)) {
          d = this.distanceTo(player);
          if (d < distance) {
            target = player;
            distance = d;
          }
        }
      }
      return target;
    };

    Robot.prototype.goAttack = function(target) {
      if (this.distanceTo(target) < this.attackRange) {
        return this.attack(target);
      } else {
        if (this.distanceTo(target) > 100 && Math.random() < 0.02) {
          return this.setState("cast");
        } else {
          return this.moveTo([target.x, target.y]);
        }
      }
    };

    Robot.prototype.update = function(game) {
      var target;
      if (this.state === 'hurt') {
        target = this.enemyInRange(game.players);
        if (target !== null) {
          this.currentDestination = [target.x, target.y];
        }
      }
      if (this.state === "cast") {
        return;
      }
      if (!this.checkState()) {
        return;
      }
      target = this.enemyInRange(game.players);
      if (target === null) {
        return this.randomWalk();
      } else {
        return this.goAttack(target);
      }
    };

    return Robot;

  })(object);

  module.exports = Robot;

}).call(this);
