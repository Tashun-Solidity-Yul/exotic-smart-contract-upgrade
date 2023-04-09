const hre = require("hardhat");
const fs = require("fs");
const contractOneABI =  JSON.parse(fs.readFileSync("./artifacts/contracts/MetamorphicPattern/mock/ContractOne.sol/ContractOne.json", "utf8"));

async function main() {
    const destructingContract = "0x2B27C8d4b2CbdEdFF27A22167B0510De403a3CC2";
    const attachedContract = await hre.ethers.getContractAt("ContractOne", destructingContract)
    // const a =await attachedContract.initialize()
    // await a.wait()
    console.log(await attachedContract.test())
    await attachedContract.destroy();

}


// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
