const DeployAll = artifacts.require("DeployAll");

module.exports = function(deployer) {
  deployer.deploy(DeployAll);
};
