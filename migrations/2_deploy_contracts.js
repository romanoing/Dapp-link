var link = artifacts.require("link");
var string = artifacts.require("StringUtils");

async function doDeploy(deployer, netowrk) {
  await deployer.deploy(string);
  await deployer.link(string, link);
  await deployer.deploy(link, {
    gas: 4500000
  });

}
module.exports = (deployer, network) => {
  deployer.then(async() => {
    await doDeploy(deployer, network);
  });
};