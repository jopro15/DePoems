var DePoems = artifacts.require("./DePoems.sol");
var Token = artifacts.require("./Token.sol");


module.exports = async function(deployer) {


  await deployer.deploy(Token);
  const token = await Token.deployed()

  // Deploy EthSwap
  await deployer.deploy(DePoems, token.address);
  const dep = await DePoems.deployed()

  

  // Transfer all tokens to EthSwap (1 million)
  await token.transfer(dep.address, '1000000000000000000000000')
};
