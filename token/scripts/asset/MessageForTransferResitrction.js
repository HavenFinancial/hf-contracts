var AssetToken = artifacts.require("AssetToken")

module.exports = async function (callback) {
    try {
        var assetToken = await AssetToken.deployed()

        console.log(await assetToken.messageForTransferRestriction(0))
        console.log(await assetToken.messageForTransferRestriction(1))
        console.log(await assetToken.messageForTransferRestriction(2))
        console.log(await assetToken.messageForTransferRestriction(3))
    } catch (e) {
        console.log(e)
    }
}
