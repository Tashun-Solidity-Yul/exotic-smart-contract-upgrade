const hre = require("hardhat");

async function main() {
    let metamorphicContractFactory = await (await hre.ethers.getContractFactory("MetamorphicContractFactory")).deploy("0x608060405260603373ffffffffffffffffffffffffffffffffffffffff166357b9f5236040518163ffffffff1660e01b815260040160006040518083038186803b15801561004c57600080fd5b505afa158015610060573d6000803e3d6000fd5b505050506040513d6000823e3d601f19601f82011682018060405250602081101561008a57600080fd5b8101908080516401000000008111156100a257600080fd5b828101905060208101848111156100b857600080fd5b81518560018202830111640100000000821117156100d557600080fd5b505092919050505090506000816020018251808234f092505050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141561012957600080fd5b8073ffffffffffffffffffffffffffffffffffffffff16fffe");
    console.log(metamorphicContractFactory.address);
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
