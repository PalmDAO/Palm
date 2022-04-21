const Palm = artifacts.require("Palm");
const PalmGovernor = artifacts.require("PalmGovernor");

module.exports = async function(deployer) {
    await deployer.deploy(Palm, 1000);
    await deployer.deploy(PalmGovernor, Palm.address);
};
