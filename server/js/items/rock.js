item_schema = {
    info: {
        maxhp: 300,
        width: 70,
        height: 70,
        collisionHeight: 20,
        collisionWidth: 20
    },
    spriteSheetInfo: {
        animations: {
            idle: {
                frames: [0, 0, 0],
                frequency: 10
            },
            run: {
                frames: [0, 1, 2],
                frequency: 10
            },
            hurt: {
                frames: [0, 1, 2, 1],
                next: "idle",
                frequency: 10
            }
        },
        images: ["assets/spritesheets/items/rock.png"],
        frames: {
            height: 60,
            width: 60,
            regX: 30,
            regY: 30
        }
    },
    gotHit: function(damage, direction) {
        //direction indicates where the hit come from
        if (this.state == "removed") {
            return
        }
        this.hp -= damage;
        if (this.hp <= 0) {
            this.setState('removed');
        } else {
            this.setState('hurt')
            this.faceDirection = direction;
            this.moveStep(this.counterDirection(direction), 5);
        }
    },
    collide: function(direction) {
        if (this.direction == "No") {
            this.direction = direction;
        } else {
            this.reverseDirection();
            this.moveStep();
        }
        this.speed = 1;
        this.setState('collided');
    }
}

module.exports = item_schema