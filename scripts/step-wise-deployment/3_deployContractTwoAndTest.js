const hre = require("hardhat");
const fs = require("fs");
const contractTwoABI =  JSON.parse(fs.readFileSync("./artifacts/contracts/MetamorphicPattern/mock/ContractTwo.sol/ContractTwo.json", "utf8"));

async function main() {
    // let metamorphicContractFactory =  (await hre.ethers.getContractAt("MetamorphicContractFactory", "0x1697E89B7c657bB50415e13ca77e42351cAC7a9C")) ;
    let metamorphicContractFactory =  (await hre.ethers.getContractAt("MetamorphicContractFactory", "0x9b60570a3Ff3D9f06a627241C0AAb9f7D95b23d4")) ;
    console.log(metamorphicContractFactory.address);
    // const salt = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000002";
    const salt = "0x09888Addf726E6B04dBc6bd8BFE5Bf4A924D597F000000000000000000000007";
    let tnx1 = await metamorphicContractFactory.deployMetamorphicContract(salt,contractTwoABI.bytecode, "0x")
    let receipt = await tnx1.wait();
    console.log(receipt.events[0].args);
    let metamorphicContract = receipt.events[0].args.metamorphicContract
    let implementationContract = receipt.events[0].args.newImplementation
    console.log(metamorphicContract);
    console.log(implementationContract);

    const attachedContractTwo = await hre.ethers.getContractAt("ContractOne", metamorphicContract)
    console.log(await attachedContractTwo.test())
    const a =await attachedContractTwo.initialize()
    await a.wait()
    console.log(await attachedContractTwo.test())
    await attachedContractOne.destroy();
}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
