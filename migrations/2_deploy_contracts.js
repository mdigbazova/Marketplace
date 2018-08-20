var Marketplace = artifacts.require("Marketplace");

var StoreItemLib = artifacts.require("StoreItemLib");
var SafeMath = artifacts.require("SafeMath"); // lib

module.exports = function(deployer) {
    deployer.deploy(StoreItemLib);
    deployer.link(StoreItemLib, Marketplace);
    deployer.deploy(SafeMath);
    deployer.link(SafeMath, Marketplace);
    deployer.deploy(Marketplace);
};