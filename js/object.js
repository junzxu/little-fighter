// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.Object = (function() {
    function Object(name, type, x, y, stage, arena) {
      this.name = name;
      this.type = type;
      this.x = x;
      this.y = y;
      this.stage = stage;
      this.arena = arena;
      this.collide = __bind(this.collide, this);
      this.collisionHandler = __bind(this.collisionHandler, this);
      this.moveStep = __bind(this.moveStep, this);
      this.id;
      this.type;
      this.hp;
      this.mass = 1;
      this.speed = 0;
      this.originSpeed = 5;
      this.collisionHeight = 20;
      this.collisionWidth = 10;
      this.spriteSheetInfo;
      this.SpriteSheet;
      this.object = null;
      this.objectSpriteSheet;
      this.direction;
      this.stage;
      this.arena;
      this.magicState = "ready";
      this.init();
    }

    Object.prototype.init = function() {
      if (this.spriteSheetInfo) {
        return this.SpriteSheet = new createjs.SpriteSheet(this.spriteSheetInfo);
      }
    };

    Object.prototype.get = function() {
      return this.object;
    };

    Object.prototype.reverseDirection = function() {
      switch (this.direction) {
        case "right":
          this.direction = "left";
          break;
        case "left":
          this.direction = "right";
          break;
        case "up":
          this.direction = "down";
          break;
        case "down":
          this.direction = "up";
          break;
        case "No":
          return;
      }
      return console.log(this.name + ' reversed to ' + this.direction);
    };

    Object.prototype.moveStep = function(direction) {
      var bound;
      bound = this.arena.getBound();
      switch (direction) {
        case "left":
          if (this.direction !== "left") {
            this.direction = "left";
          }
          if (this.get().x - this.speed > bound['x1']) {
            this.get().x -= this.speed;
          } else {
            this.get().x += this.speed;
          }
          break;
        case "right":
          if (this.direction !== "right") {
            this.direction = "right";
          }
          if (this.get().x + this.speed < bound['x2']) {
            this.get().x += this.speed;
          } else {
            this.get().x -= this.speed;
          }
          break;
        case "down":
          this.direction = "down";
          if (this.get().y + this.speed < bound['y2']) {
            this.get().y += this.speed;
          } else {
            this.get().y -= this.speed;
          }
          break;
        case "up":
          this.direction = "up";
          if (this.get().y - this.speed > bound['y1']) {
            this.get().y -= this.speed;
          } else {
            this.get().y += this.speed;
          }
      }
      return this.updateCoords();
    };

    Object.prototype.moveTo = function(x, y) {
      var bound;
      bound = this.arena.getBound();
      if (x > bound['x1'] && x < bound['x2'] && y > bound['y1'] && y < bound['y2']) {
        this.get().x = x;
        this.get().y = y;
        return this.updateCoords();
      } else {
        return console.log('invalid coordinates: (' + x + ',' + y + ')');
      }
    };

    Object.prototype.updateCoords = function() {
      this.get().localToGlobal(this.x, this.y);
      this.x = this.get().x;
      return this.y = this.get().y;
    };

    Object.prototype.getRect = function() {
      var x1, x2, y1, y2;
      x1 = this.get().getBounds().x + this.get().x;
      y1 = this.get().getBounds().y + this.get().y;
      x2 = this.get().getBounds().x + this.get().x + this.get().getBounds().width;
      y2 = this.get().getBounds().y + this.get().y + this.get().getBounds().height;
      return {
        "x1": x1,
        "x2": x2,
        "y1": y1,
        "y2": y2
      };
    };

    Object.prototype.getCollisionRect = function() {
      var x1, x2, y1, y2;
      x1 = this.get().getBounds().x + this.get().x + this.collisionWidth;
      y1 = this.get().getBounds().y + this.get().y + this.collisionHeight;
      x2 = this.get().getBounds().x + this.get().x + this.get().getBounds().width - this.collisionWidth;
      y2 = this.get().getBounds().y + this.get().y + this.get().getBounds().height - this.collisionHeight;
      return {
        "x1": x1,
        "x2": x2,
        "y1": y1,
        "y2": y2
      };
    };

    Object.prototype.gotHit = function(direction) {
      return console.log("nothing happened");
    };

    Object.prototype.detectCollision = function() {
      var object, otherObject, rect1, rect2, _i, _len, _ref, _results;
      object = this;
      rect1 = this.getCollisionRect();
      _ref = this.arena.getObjects();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        otherObject = _ref[_i];
        if (object.id === otherObject.id) {
          continue;
        }
        rect2 = otherObject.getCollisionRect();
        if (!((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2) || (rect2.y1 > rect1.y2) || (rect2.y2 < rect1.y1))) {
          console.log(object.name + 'collide with' + otherObject.name);
          _results.push(this.collisionHandler(object, otherObject));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Object.prototype.updateSpeed = function(a, b) {
      var v1, v2;
      v1 = a.speed;
      v2 = b.speed;
      if (a.direction === "No") {
        a.direction = b.direction;
        b.reverseDirection();
      }
      if (b.direction === "No") {
        b.direction = a.direction;
        a.reverseDirection();
      }
      if (a.direction !== "No" && b.direction !== "No") {
        a.reverseDirection();
        b.reverseDirection();
      }
      a.speed = Math.abs(a.mass - b.mass) / (a.mass + b.mass) * v1;
      a.speed += (2 * b.mass) / (a.mass + b.mass) * v2;
      b.speed = (2 * b.mass) / (a.mass + b.mass) * v1;
      b.speed += Math.abs(a.mass - b.mass) / (a.mass + b.mass) * v2;
      a.state = 'disabled';
      b.state = 'disabled';
      a.get().addEventListener("tick", this.collide);
      return b.get().addEventListener("tick", this.collide);
    };

    Object.prototype.collisionHandler = function(a, b) {
      this.updateSpeed(a, b);
      createjs.Tween.get(a, {
        loop: false
      }).wait(200).call(((function(_this) {
        return function() {
          a.idle();
          return a.get().removeEventListener("tick", _this.collide);
        };
      })(this)));
      return createjs.Tween.get(b, {
        loop: false
      }).wait(200).call(((function(_this) {
        return function() {
          b.idle();
          return b.get().removeEventListener("tick", _this.collide);
        };
      })(this)));
    };

    Object.prototype.collide = function(event) {
      var object;
      object = event.target;
      switch (this.direction) {
        case "right":
          object.x += this.speed;
          break;
        case "left":
          object.x -= this.speed;
          break;
        case "up":
          object.y -= this.speed;
          break;
        case "down":
          object.y += this.speed;
      }
      this.updateCoords();
      if (this.speed <= 0) {
        return this.speed = this.originSpeed;
      }
    };

    return Object;

  })();

}).call(this);
