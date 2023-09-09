const MetaLifeHoldingReward = artifacts.require("MetaLifeHoldingReward");

module.exports = function(deployer) {
  deployer.deploy(MetaLifeHoldingReward);
};
