player_schema = {
    spriteSheetInfo: {
        animations: {
            idle: {
                frames: [0, 1, 2, 3, 2],
                frequency: 10
            },
            run: {
                frames: [20, 21, 22, 21],
                frequency: 10
            },
            attack: {
                frames: [10, 11, 12, 13, 14, 15, 16, 17],
                frequency: 10
            },
            cast: {
                frames: [10, 11],
                frequency: 10
            },
            hurt: {
                frames: [53, 54, 55],
                frequency: 10
            },
            die: {
                frames: [30, 31, 32, 33, 34, 35, 34],
                next: "lay",
                frequency: 10
            },
            lay: {
                frames: [34]
            }
        },
        images: ["assets/spritesheets/firzen.png"],
        frames: {
            height: 80,
            width: 80,
            regX: 40,
            regY: 40
        }
    },
    magicSheetInfo: {
        animations: {
            cast: {
                frames: [0, 1, 2, 3],
                frequency: 10
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

module.exports = player_schema