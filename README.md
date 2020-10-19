# sale-contract
This repositories contains the token and its pre sale contract. 

`fundsReceiver` will receive ETH invested by the investors, Whilst `owner` of the token is only allowed to pull unlock tokens after lock duration ends.

Note - `initialMint()` should be the first transaction performed by the owner of the ERC20 token by passing `saleContractAddress` to mint the tokens to the sale contract and itself for the desired allocation. This function can only be called once by the owner of the contract.

## Prerequisite
- Truffle ^5.0.0.  
- NPM ^6.4.1
- Node ^10.13.0

## Compile
```
truffle compile
```

## Migrate
```
truffle migrate
```

# Ropsten contracts

Token contract - [0xCEF08828CA92c7CE079b69bfa6EFf5641F612d87](https://ropsten.etherscan.io/address/0xCEF08828CA92c7CE079b69bfa6EFf5641F612d87#code)   
PreSale contract - [0x322C846b4f0e282a0cD277e75255B8A491145243](https://ropsten.etherscan.io/address/0x322C846b4f0e282a0cD277e75255B8A491145243#code)    
