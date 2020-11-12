const AssetToken = artifacts.require("AssetToken");

module.exports = function (deployer) {
  deployer.deploy(AssetToken, "A00001", "SK12", 1000000000, "0x00a329c0648769a73afac7f9381e08fb43dbea72", "0x731a10897d267e19b34503ad902d0a29173ba4b1");
};
