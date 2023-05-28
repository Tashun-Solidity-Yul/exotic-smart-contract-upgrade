# Diamond Patterns

This is a foundry and Hardhat project where Some Solidity based Design patterns are investigated

### SimpleDiamond
`./src/SimpleDiamond`

This consists of two facets and a diamond contract. Diamond and facets have two separate storage patterns. 
Facet storage is (namely `AppStorage`) shared across all the facets and designed in a way to avoid storage collision. 
Same storage slot is not shared across two different contracts.

Diamond storage is used mainly to store routing information and security information that is needed by the diamond which, 
acts as a proxy. 


## Metamorphic Contracts
`./contracts/MetamorphicPattern`

This contract along with the tests include How to deploy and proceed with a metamorphic contract 
(can delete itself and respawn with a different logic). Metamorphic Contract Factory and
Metapod along with Transient contract Usage and the bytecode changes upon changing the contract 
logic are depicted with an example.


# StandardDiamondPattern
`./src/StandardDiamondPattern`

Standard Diamond pattern includes a ERC20 Token and a ERC721 implementations adjusted to suit a facet pattern 
and an implementation where users can buy ERC20 Tokens, ERC721 Tokens selling the ERC20 token mentioned earlier. 
This also includes the facet upgrading logics, diamond cutting implementation along with `DiamondStorage`
implementation instead of `AppStorage`  



