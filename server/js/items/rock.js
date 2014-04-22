item_schema = {
    info: {
        maxhp: 300,
        width: 100,
        height: 100,
        collisionHeight: 10,
        collisionWidth: 10
    },
    spriteSheetInfo: {
        animations: {
            idle: {
                frames: [0, 1, 2, 3, 2],
                frequency: 10
            },
            run: {
                frames: [4, 5, 6, 7],
                frequency: 10
            },
            hurt: {
                frames: [41, 42, 43, 44],
                next: "idle",
                frequency: 10
            }
        },
        images: ["assets/spritesheets/items/rock.png"],
        frames: {
            height: 100,
            width: 100,
            regX: 50,
            regY: 50
        }
    }
}

module.exports = item_schema