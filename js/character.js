// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Character = (function(_super) {
    __extends(Character, _super);

    function Character(id, name, type, x, y, world) {
      this.id = id;
      this.name = name;
      this.type = type;
      this.x = x;
      this.y = y;
      this.world = world;
      this.setHPBar = __bind(this.setHPBar, this);
      Character.__super__.constructor.call(this, this.id, this.name, this.type, this.x, this.y, this.world);
      this.cd;
      this.number;
      this.score;
      this.character;
    }

    Character.prototype.init = function() {
      Character.__super__.init.apply(this, arguments);
      this.faceDirection = "right";
      this.attackRange = 50;
      this.isLocal = false;
      return this.lastCast = 0;
    };

    Character.prototype.build = function(spriteSheetInfo, magicSheetInfo) {
      this.spriteSheetInfo = spriteSheetInfo;
      this.magicSheetInfo = magicSheetInfo;
      this.SpriteSheet = new createjs.SpriteSheet(this.spriteSheetInfo);
      this.character = new createjs.BitmapAnimation(this.SpriteSheet);
      this.character.name = this.name;
      this.character.x = this.x;
      this.character.y = this.y;
      if (this.faceDirection === 'left') {
        this.get().scaleX = -this.get().scaleX;
      }
      return this.character.gotoAndPlay("idle");
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
      if (this.character.currentAnimation !== "run") {
        this.character.gotoAndPlay("run");
      }
      this.direction = direction;
      return this.state = "run";
    };

    Character.prototype.attack = function() {
      if (this.character.currentAnimation !== "attack") {
        this.character.gotoAndPlay("attack");
      }
      return this.state = "attack";
    };

    Character.prototype.cast = function() {
      if (this.character.currentAnimation !== "cast") {
        this.character.gotoAndPlay("cast");
        this.startCoolDown();
      }
      return this.state = "cast";
    };

    Character.prototype.die = function() {
      if (this.state !== "die") {
        if (this.character.currentAnimation !== "die") {
          this.character.gotoAndPlay("die");
          return this.state = "die";
        }
      }
    };

    Character.prototype.idle = function() {
      var animation;
      this.speed = 0;
      this.direction = "No";
      this.state = "idle";
      animation = this.animation;
      if (this.character.currentAnimation !== "idle") {
        return this.character.gotoAndPlay("idle");
      }
    };

    Character.prototype.gotHit = function(direction) {
      this.changeFaceDirection(direction);
      if (this.character.currentAnimation !== "hurt") {
        this.character.gotoAndPlay("hurt");
      }
      return this.state = "hurt";
    };

    Character.prototype.setHPBar = function(hp) {
      var percent, pnumber;
      pnumber = "#player" + this.number;
      percent = 100 * (hp / this.maxhp);
      $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').css("width", percent + "%");
      return $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').html(hp);
    };

    Character.prototype.startCoolDown = function() {
      var pnumber;
      this.lastCast = new Date().getTime();
      pnumber = "#player" + this.number;
      $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #cd').css("width", "0%");
      return setTimeout(((function(_this) {
        return function() {
          pnumber = "#player" + _this.number;
          return $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #cd').css("width", "100%");
        };
      })(this)), this.cd);
    };

    Character.prototype.setCoolDown = function(delta) {
      var percent, pnumber;
      percent = Math.floor(100 * (delta / this.cd));
      pnumber = "#player" + this.number;
      return $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #cd').css("width", percent + "%");
    };

    Character.prototype.setScore = function(score) {
      var pnumber, text;
      pnumber = "#player" + this.number;
      text = "Score:" + score;
      return $('#hud > .row > ' + pnumber + ' > .row >#stats > .score > #playerScore').html(text);
    };

    Character.prototype.update = function(object) {
      var currentTime, deltaTime;
      this.animation = object.animation;
      if (this.animation === "invisible") {
        if (this.isLocal === true) {
          this.get().alpha = 0.5;
        } else {
          this.get().visible = false;
        }
      } else {
        if (this.isLocal === true) {
          this.get().alpha = 1;
        } else {
          this.get().visible = true;
        }
      }
      if (object.score !== this.score) {
        this.setScore(object.score);
      }
      currentTime = new Date().getTime();
      deltaTime = currentTime - this.lastCast;
      if (deltaTime < this.cd) {
        this.setCoolDown(deltaTime);
      }
      if (this.state === "die" && object.state !== "die") {
        this.character.x = object.x;
        this.character.y = object.y;
        this.hp = object.hp;
        this.setHPBar(this.hp);
      }
      switch (object.state) {
        case 'die':
          this.setHPBar(0);
          return this.die();
        case 'hurt':
          this.gotHit(object.faceDirection);
          this.hp = object.hp;
          return this.setHPBar(this.hp);
        case 'run':
          this.changeFaceDirection(object.faceDirection);
          this.run(object.direction);
          this.get().x = object.x;
          return this.get().y = object.y;
        case 'collided':
          this.get().x = object.x;
          this.get().y = object.y;
          this.hp = object.hp;
          return this.setHPBar(this.hp);
        case 'attack':
          return this.attack();
        case 'cast':
          return this.cast();
        case 'idle':
          return this.idle();
      }
    };

    return Character;

  })(object);

}).call(this);
