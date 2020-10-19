const ERC20Token = artifacts.require("ERC20Token");
const PreSale = artifacts.require("PreSale");

module.exports = function(deployer, network, accounts) {
  let name = "DealDefi Token";
  let symbol = "DDFI";

  if (network === "development") {
    let fundsReceiver = accounts[0];

    return deployer.deploy(ERC20Token, name, symbol).then(() => {
      return deployer.deploy(PreSale, ERC20Token.address, fundsReceiver);
    });

  } else if (network === "ropsten") {
    let fundsReceiver = "0x8213Fb521A39daFf48e0c6cEA19DA6458dA1264e";

    return deployer.deploy(ERC20Token, name, symbol).then(() => {
      return deployer.deploy(PreSale, ERC20Token.address, fundsReceiver);
    });

  } else if (network === "mainnet") {
    let fundsReceiver = "0xAb012ed9C8Dd6C955e3652c746888F0FDD686273";

    return deployer.deploy(ERC20Token, name, symbol).then(() => {
      return deployer.deploy(PreSale, ERC20Token.address, fundsReceiver);
    });
    
  }

}
