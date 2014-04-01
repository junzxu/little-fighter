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
                frames: [70, 71, 72],
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
        images: ["assets/spritesheets/firzen/firzen.png", "assets/spritesheets/firzen/firzen_cast.png"],
        frames: {
            height: 80,
            width: 80,
            regX: 40,
            regY: 40
        }
    },
    magicSheetInfo: {
        name: 'wave',
        animations: {
            cast: {
                frames: [0, 1],
                frequency: 10
            }
        },
        images: ["assets/spritesheets/magic/p1b.png"],
        frames: {
            height: 55,
            width: 126,
            regX: 63,
            regY: 27
        }
    }
}

module.exports = player_schema