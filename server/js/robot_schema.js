robot_schema = {
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
            attack: {
                frames: [10, 11, 12, 13, 14, 15, 16, 17],
                next: "idle",
                frequency: 10
            },
            hurt: {
                frames: [41, 42, 43, 44],
                next: "idle",
                frequency: 10
            },
            die: {
                frames: [16, 15, 14]
            }
        },
        images: ["assets/spritesheets/julian.png"],
        frames: {
            height: 100,
            width: 80,
            regX: 40,
            regY: 40
        }
    },
    magicSheetInfo: {
        animations: {
            cast: {
                frames: [20, 21, 22],
                frequency: 5
            }
        },
        images: ["assets/spritesheets/magic.png"],
        frames: {
            height: 40,
            width: 40,
            regX: 20,
            regY: 20
        }
    }
}

module.exports = robot_schema