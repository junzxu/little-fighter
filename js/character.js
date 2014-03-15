// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Character = (function(_super) {
    __extends(Character, _super);

    function Character(name, type, x, y, world) {
      this.name = name;
      this.type = type;
      this.x = x;
      this.y = y;
      this.world = world;
      Character.__super__.constructor.apply(this, arguments);
      this.hp = 100;
      this.cd = 300;
      this.attackRange = 50;
      this.number;
      this.character;
      this.faceDirection = "right";
    }

    Character.prototype.init = function() {
      var data;
      Character.__super__.init.apply(this, arguments);
      this.state = "idle";
      this.direction = "No";
      if (this.type === "robot") {
        data = eval(robot_schema);
      } else {
        data = eval(player_schema);
      }
      this.spriteSheetInfo = data.spriteSheetInfo;
      this.magicSheetInfo = data.magicSheetInfo;
      console.log('init');
      this.SpriteSheet = new createjs.SpriteSheet(this.spriteSheetInfo);
      this.character = new createjs.BitmapAnimation(this.SpriteSheet);
      this.character.x = this.x;
      this.character.y = this.y;
      this.character.gotoAndPlay("idle");
      return this.character.addEventListener("animationend", (function(evt) {
        switch (this.state) {
          case 'die':
            this.setState('idle');
            this.rebirth();
            break;
          case 'disabled':
            break;
          default:
            return this.idle();
        }
      }).bind(this));
    };

    Character.prototype.addToWorld = function(world) {
      world.addPlayer(this);
      return this.world = world;
    };

    Character.prototype.get = function() {
      return this.character;
    };

    Character.prototype.changeFaceDirection = function(direction) {
      if (this.faceDirection === direction) {

      } else {
        this.faceDirection = direction;
        return this.get().scaleX = -this.get().scaleX;
      }
    };

    Character.prototype.run = function(direction) {
      if (!this.checkState()) {
        return;
      }
      if (this.character.currentAnimation !== "run") {
        this.character.gotoAndPlay("run");
      }
      this.setState("run");
      this.speed = this.originSpeed;
      this.moveStep(direction);
      if (direction === "left" || direction === "right") {
        this.changeFaceDirection(direction);
      }
      return this.detectCollision();
    };

    Character.prototype.attack = function() {
      var distance, player, _ref;
      if (this.checkState()) {
        if (this.state !== "attack") {
          this.state = "attack";
        }
        if (this.character.currentAnimation !== "attack") {
          this.character.gotoAndPlay("attack");
        }
        _ref = this.world.getNearestCharacter(this), player = _ref[0], distance = _ref[1];
        if (player !== null && distance < this.attackRange && this.faceDirection === this.realtiveDirection(player)) {
          return player.gotHit(10, this.counterDirection(this.faceDirection));
        }
      }
    };

    Character.prototype.cast = function() {
      var bound, m, width, x;
      if (this.checkState() && this.magicState === 'ready') {
        bound = this.getRect();
        width = bound.x2 - bound.x1;
        x = this.faceDirection === 'right' ? this.x + width : this.x - width;
        m = new Magic('blue', 'magic', x, this.y, this.world, this.character, this.magicSheetInfo, this.faceDirection);
        m.cast();
        this.magicState = 'preparing';
        return createjs.Tween.get(this.character, {
          loop: false
        }).wait(this.cd).call(((function(_this) {
          return function() {
            return _this.magicState = "ready";
          };
        })(this)));
      }
    };

    Character.prototype.rebirth = function() {
      var bound, x, y;
      this.world.get().removeChild(this.character);
      bound = this.world.getBound();
      x = Math.floor(Math.random() * bound.x2);
      y = Math.floor(Math.random() * bound.y2);
      this.character.x = x;
      this.character.y = y;
      this.updateCoords();
      this.hp = 100;
      return createjs.Tween.get(this.character, {
        loop: false
      }).wait(3000).call(((function(_this) {
        return function() {
          _this.setHPBar(100);
          _this.world.get().addChild(_this.character);
          return _this.character.idle();
        };
      })(this)));
    };

    Character.prototype.idle = function() {
      this.setState('idle');
      this.speed = 0;
      this.direction = "No";
      if (this.character.currentAnimation !== "idle") {
        return this.character.gotoAndPlay("idle");
      }
    };

    Character.prototype.gotHit = function(damage, direction) {
      var bound;
      console.log('current hp: ' + this.hp);
      this.hp -= damage;
      this.setHPBar(this.hp);
      if (this.hp <= 0) {
        this.character.gotoAndPlay("die");
        return this.setState('die');
      } else {
        this.setState('hurt');
        this.changeFaceDirection(direction);
        this.character.gotoAndPlay("hurt");
        bound = this.world.getBound();
        return this.moveStep(direction);
      }
    };

    Character.prototype.setState = function(state) {
      return this.state = state;
    };

    Character.prototype.checkState = function() {
      var _ref;
      if (this.state === "disabled" || ((_ref = this.character.currentAnimation) === "hurt" || _ref === "attack")) {
        return false;
      } else {
        return true;
      }
    };

    Character.prototype.setHPBar = function(hp) {
      var pnumber;
      pnumber = "#player" + this.number;
      $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').css("width", hp + "%");
      return $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').html(hp);
    };

    return Character;

  })(Object);

}).call(this);
