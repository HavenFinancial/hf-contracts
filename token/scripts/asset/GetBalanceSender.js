var AssetToken = artifacts.require("AssetToken")

module.exports = async function(callback) {
    try {
        var assetToken = await AssetToken.deployed()

        var balance = await assetToken.balanceOf("0x00a329c0648769a73afac7f9381e08fb43dbea72")

        console.log(balance.toString())
    } catch (e) {
        console.log(e)
    }
}
