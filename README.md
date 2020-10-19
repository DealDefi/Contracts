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

Token contract - [0xc1385730edf2Dfbbb7Aac6199D50a5D6098A3509](https://ropsten.etherscan.io/address/0xc1385730edf2Dfbbb7Aac6199D50a5D6098A3509#code)   
PreSale contract - [0x1b74fE5A1053975e33914e41dA206D6B3112aa33](https://ropsten.etherscan.io/address/0x1b74fE5A1053975e33914e41dA206D6B3112aa33#code)    
