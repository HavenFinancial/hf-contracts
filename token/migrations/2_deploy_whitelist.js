const ManagedWhitelist = artifacts.require("ManagedWhitelist");

module.exports = function (deployer) {
  deployer.deploy(ManagedWhitelist);
};
