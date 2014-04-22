magic_schema = {
    info: {
        name: 'invisible',
        cd: 8000,
        damage: 0,
        originSpeed: 0,
        width: 0,
        height: 0
    },
    magicSheetInfo: null,
    magic: function(game, player, id) {
        player.idle()
        player.animation = "invisible"
    }
}

module.exports = magic_schema