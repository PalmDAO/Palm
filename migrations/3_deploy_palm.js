const Palm = artifacts.require("Palm");
const PeoplesGovernor = artifacts.require("PeoplesGovernor");
const WhaleGovernor = artifacts.require("WhaleGovernor");

module.exports = async function(deployer) {
    deployer.deploy(Palm, 1000);
    deployer.deploy(PeoplesGovernor, Palm.address);
    deployer.deploy(WhaleGovernor, Palm.address);
};
