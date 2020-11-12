var AssetToken = artifacts.require("AssetToken")

module.exports = async function(callback) {
    try {
        var assetToken = await AssetToken.deployed()

        var balance = await assetToken.balanceOf("0x2973F99085BC2dc5d438c17b693b2d7f857b0dBC")

        console.log(balance.toString())
    } catch (e) {
        console.log(e)
    }
}
