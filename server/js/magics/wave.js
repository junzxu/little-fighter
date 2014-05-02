magic_schema = {
    info: {
        name: 'wave',
        cd: 1000,
        damage: 10,
        originSpeed: 5,
        width: 126,
        height: 55
    },
    magicSheetInfo: {
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
    },
    magic: function(game, player, id) {
        bound = player.getRect();
        width = bound.x2 - bound.x1;
        x = player.faceDirection === 'right' ? bound.x2 : bound.x1;
        game.addMagic(id, player.magicInfo, x, player.y, player.id, player.faceDirection)
    }
}

module.exports = magic_schema