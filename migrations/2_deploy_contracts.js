const MyToken = artifacts.require("MyToken");
const AdvancedContract = artifacts.require("AdvancedContract");

module.exports = function(deployer) {
  deployer.deploy(MyToken, "1000000000000000000000000"); // 1 million tokens
  deployer.deploy(AdvancedContract);
};