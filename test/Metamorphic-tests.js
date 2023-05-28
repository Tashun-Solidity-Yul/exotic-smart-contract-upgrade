const hre = require("hardhat");
const {kakuna} = require("../scripts/kakuna.js");

describe("",()=> {
    let deployer;
    describe("",()=> {
        before("Before Metamorphic Test", async () => {
            [deployer] = await hre.ethers.getSigners();

        })
        it("",async () => {
            // deploying ImmutableCreate2Factory 
            let immutableCreate2Factory = await (await hre.ethers.getContractFactory("ImmutableCreate2Factory", deployer)).deploy();
            // deploying MetamorphicContractFactory with Transient contract bytecode
            let metamorphicContractFactory = await (await hre.ethers.getContractFactory("MetamorphicContractFactory", deployer)).deploy("0x608060408190527f57b9f52300000000000000000000000000000000000000000000000000000000815260609033906357b9f5239060849060009060048186803b15801561004c57600080fd5b505afa158015610060573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052602081101561008957600080fd5b8101908080516401000000008111156100a157600080fd5b820160208101848111156100b457600080fd5b81516401000000008111828201871017156100ce57600080fd5b505092919050505090506000816020018251808234f0925050506001600160a01b0381166100fb57600080fd5b806001600160a01b0316fffe");

            // New implementation contract
            const ContractOneInstance = await hre.ethers.getContractFactory("ContractOne", deployer);
            let contractOne = await ContractOneInstance.deploy();
            const ContractTwoInstance = await hre.ethers.getContractFactory("ContractTwo", deployer);
            let contractTwo = await ContractTwoInstance.deploy();
            // CodeCheck contract
            let codeCheckContract = await (await hre.ethers.getContractFactory("CodeCheck", deployer)).deploy();
            // Kakuna test contract
            let kakunaBasicContract = await (await hre.ethers.getContractFactory("KakunaBasicTest", deployer)).deploy();
            let MetapodUpdated = await hre.ethers.getContractFactory("MetapodUpdated");
            // const metaPodUpdatedDeployTnx1 = ;
            const deployed = await MetapodUpdated.deploy()
            // console.log(deployed.address)
            // await metaPodUpdatedDeployTnx1.wait();
            // const metaPodUpdatedDeployTnx = await deployed.deploy("0x00", ContractOneInstance.bytecode);
            const requiredPrelude = await deployed.getPrelude("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000");
            // console.log(getFinalByteCode(requiredPrelude, ContractOneInstance))
            const metaPodUpdatedDeployTnx = await deployed.deploy("0x00", getFinalByteCode(requiredPrelude, ContractOneInstance));
            const prelude = Buffer.from(requiredPrelude.slice(2), 'hex').toString("hex")
            // console.log(prelude)
            // console.log(prelude.length)
            //
            // console.log(ContractOneInstance.bytecode)
            // console.log(ContractOneInstance.bytecode.substring(0,ContractOneInstance.bytecode.indexOf("60c5")));
            // console.log(61);
            // console.log("0" + (prelude.length + parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16)).toString(16));
            // // console.log((prelude.length + parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16)));
            // console.log(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 4 , ContractOneInstance.bytecode.indexOf("6080604052", 12) ));
            // console.log(prelude);
            // console.log(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("6080604052", 3) ));

        })

        it("",async () => {
            // deploying ImmutableCreate2Factory
            let immutableCreate2Factory = await (await hre.ethers.getContractFactory("ImmutableCreate2Factory", deployer)).deploy();
            // deploying MetamorphicContractFactory with Transient contract bytecode
            let metamorphicContractFactory = await (await hre.ethers.getContractFactory("MetamorphicContractFactory", deployer)).deploy("0x608060408190527f57b9f52300000000000000000000000000000000000000000000000000000000815260609033906357b9f5239060849060009060048186803b15801561004c57600080fd5b505afa158015610060573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052602081101561008957600080fd5b8101908080516401000000008111156100a157600080fd5b820160208101848111156100b457600080fd5b81516401000000008111828201871017156100ce57600080fd5b505092919050505090506000816020018251808234f0925050506001600160a01b0381166100fb57600080fd5b806001600160a01b0316fffe");

            // New implementation contract
            const ContractOneInstance = await hre.ethers.getContractFactory("ContractOne", deployer);
            let contractOne = await ContractOneInstance.deploy();
            const ContractTwoInstance = await hre.ethers.getContractFactory("ContractTwo", deployer);
            let contractTwo = await ContractTwoInstance.deploy();
            // CodeCheck contract
            let codeCheckContract = await (await hre.ethers.getContractFactory("CodeCheck", deployer)).deploy();
            // Kakuna test contract
            let kakunaBasicContract = await (await hre.ethers.getContractFactory("KakunaBasicTest", deployer)).deploy();
            let MetapodUpdated = await hre.ethers.getContractFactory("MetapodUpdated");
            // const metaPodUpdatedDeployTnx1 = ;
            const deployed = await MetapodUpdated.deploy()
            // console.log(deployed.address)
            // await metaPodUpdatedDeployTnx1.wait();
            // const metaPodUpdatedDeployTnx = await deployed.deploy("0x00", ContractOneInstance.bytecode);
            const requiredPrelude = await deployed.getPrelude("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000");
            // console.log(getFinalByteCode(requiredPrelude, ContractOneInstance))
            const metaPodUpdatedDeployTnx1 = await deployed.deploy("0x00", getFinalByteCode(requiredPrelude, ContractOneInstance));
            const m = (await metaPodUpdatedDeployTnx1.wait()).events[0].args;
            const prelude = Buffer.from(requiredPrelude.slice(2), 'hex').toString("hex")
            // const a = await metamorphicContractFactory.deployMetamorphicContract("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000",getFinalByteCode(requiredPrelude, ContractOneInstance),"0x")

            // const b = await a.wait()
            // console.log(b.events[0].args.metamorphicContract)
            const deployedAdd = await hre.ethers.getContractAt("ContractOne", m.metamorphicContract)
            // console.log(m)
            // const metaPodUpdatedDeployTnx3 = await deployed.recover("0x00");
            // const metaPodUpdatedDeployTnx2 = await deployed.destroy("0x00");
            // console.log(await deployedAdd.test())
            // console.log(prelude)
            // console.log(prelude.length)
            //
            // console.log(ContractOneInstance.bytecode)
            // console.log(ContractOneInstance.bytecode.substring(0,ContractOneInstance.bytecode.indexOf("60c5")));
            // console.log(61);
            // console.log("0" + (prelude.length + parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16)).toString(16));
            // // console.log((prelude.length + parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16)));
            // console.log(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 4 , ContractOneInstance.bytecode.indexOf("6080604052", 12) ));
            // console.log(prelude);
            // console.log(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("6080604052", 3) ));
            await kakuna("ContractOne",requiredPrelude, true)
        })
        it("",async () => {
            // deploying ImmutableCreate2Factory
            let immutableCreate2Factory = await (await hre.ethers.getContractFactory("ImmutableCreate2Factory", deployer)).deploy();
            // deploying MetamorphicContractFactory with Transient contract bytecode
            let metamorphicContractFactory = await (await hre.ethers.getContractFactory("MetamorphicContractFactory", deployer)).deploy("0x608060408190527f57b9f52300000000000000000000000000000000000000000000000000000000815260609033906357b9f5239060849060009060048186803b15801561004c57600080fd5b505afa158015610060573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052602081101561008957600080fd5b8101908080516401000000008111156100a157600080fd5b820160208101848111156100b457600080fd5b81516401000000008111828201871017156100ce57600080fd5b505092919050505090506000816020018251808234f0925050506001600160a01b0381166100fb57600080fd5b806001600160a01b0316fffe");

            // New implementation contract
            const ContractOneInstance = await hre.ethers.getContractFactory("ContractOne", deployer);
            let contractOne = await ContractOneInstance.deploy();
            const ContractTwoInstance = await hre.ethers.getContractFactory("ContractTwo", deployer);
            let contractTwo = await ContractTwoInstance.deploy();
            // CodeCheck contract
            let codeCheckContract = await (await hre.ethers.getContractFactory("CodeCheck", deployer)).deploy();
            // Kakuna test contract
            let kakunaBasicContract = await (await hre.ethers.getContractFactory("KakunaBasicTest", deployer)).deploy();
            let MetapodUpdated = await hre.ethers.getContractFactory("MetapodUpdated");
            // const metaPodUpdatedDeployTnx1 = ;
            const deployed = await MetapodUpdated.deploy()
            // console.log(deployed.address)
            // await metaPodUpdatedDeployTnx1.wait();
            // const metaPodUpdatedDeployTnx = await deployed.deploy("0x00", ContractOneInstance.bytecode);
            const requiredPrelude = await deployed.getPrelude("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000");
            // console.log(getFinalByteCode(requiredPrelude, ContractOneInstance))
            // const metaPodUpdatedDeployTnx1 = await deployed.deploy("0x00", getFinalByteCode(requiredPrelude, ContractOneInstance));
            const metaPodUpdatedDeployTnx1 = await deployed.deploy("0x00", "0x608060405234801561001057600080fd5b5060f68061001f6000396000f3fe730165878a594ca255338adfa4d48449f69242eb8f331860305773f0da4a0ba5cf57d095da076857e44fe0bc1ece2fff5b6080604052348015604057600080fd5b5060043610606d5760003560e01c80638129fc1c14607257806383197ef014607a578063f8a8fd6d146082575b600080fd5b6078609e565b005b604f60a8565b005b608860c1565b6040518082815260200191505060405180910390f35b6001600081905550565b3373ffffffffffffffffffffffffffffffffffffffff16ff5b6000805490509056fea165627a7a723058204f4a1d6ef6ed8cb7999e54c18b69ad015bebce041aad75ba2e67f077401626580029");
            const m = (await metaPodUpdatedDeployTnx1.wait()).events[0].args;
            const prelude = Buffer.from(requiredPrelude.slice(2), 'hex').toString("hex")
            // const a = await metamorphicContractFactory.deployMetamorphicContract("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266000000000000000000000000",getFinalByteCode(requiredPrelude, ContractOneInstance),"0x")

            // const b = await a.wait()
            // console.log(b.events[0].args.metamorphicContract)
            const deployedAdd = await hre.ethers.getContractAt("ContractOne", m.metamorphicContract)
            // console.log(m)
            // const metaPodUpdatedDeployTnx3 = await deployed.recover("0x00");
           await deployedAdd.initialize()
            console.log(await deployedAdd.test())
            const metaPodUpdatedDeployTnx2 = await deployed.destroy("0x00");
            const metaPodUpdatedDeployTnx5 = await deployed.deploy("0x00", "0x608060405234801561001057600080fd5b5060f68061001f6000396000f3fe730165878a594ca255338adfa4d48449f69242eb8f331860305773f0da4a0ba5cf57d095da076857e44fe0bc1ece2fff5b6080604052348015604057600080fd5b5060043610606d5760003560e01c80638129fc1c14607257806383197ef014607a578063f8a8fd6d146082575b600080fd5b6078609e565b005b604f60a8565b005b608860c1565b6040518082815260200191505060405180910390f35b6001600081905550565b3373ffffffffffffffffffffffffffffffffffffffff16ff5b6000805490509056fea165627a7a723058204f4a1d6ef6ed8cb7999e54c18b69ad015bebce041aad75ba2e67f077401626580029");
            console.log(await deployedAdd.test())
            // console.log(prelude)
            // console.log(prelude.length)
            //
            // console.log(ContractOneInstance.bytecode)
            // console.log(ContractOneInstance.bytecode.substring(0,ContractOneInstance.bytecode.indexOf("60c5")));
            // console.log(61);
            // console.log("0" + (prelude.length + parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16)).toString(16));
            // // console.log((prelude.length + parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16)));
            // console.log(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 4 , ContractOneInstance.bytecode.indexOf("6080604052", 12) ));
            // console.log(prelude);
            // console.log(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("6080604052", 3) ));
            // await kakuna("ContractOne",requiredPrelude, true)
        })

        it("",async () => {
            let immutableCreate2Factory = (await hre.ethers.getContractAt("ImmutableCreate2Factory", "0x000000000063b99B8036c31E91c64fC89bFf9ca7"));
            // deploying MetamorphicContractFactory with Transient contract bytecode
            // let metamorphicContractFactory = (await hre.ethers.getContractAt("MetamorphicContractFactory", "0x00000000e82eb0431756271F0d00CFB143685e7B"));
            // let metamorphicContractFactory = await hre.ethers.getContractAt("MetamorphicContractFactory", "0x00000000e82eb0431756271F0d00CFB143685e7B");
            let metamorphicContractFactory = await (await hre.ethers.getContractFactory("MetamorphicContractFactory")).deploy("0x608060408190527f57b9f52300000000000000000000000000000000000000000000000000000000815260609033906357b9f5239060849060009060048186803b15801561004c57600080fd5b505afa158015610060573d6000803e3d6000fd5b505050506040513d6000823e601f3d908101601f19168201604052602081101561008957600080fd5b810190808051640100000000");
            let Metapod = await hre.ethers.getContractFactory("Metapod");
            let MetapodContract = await hre.ethers.getContractAt("Metapod","0x00000000002B13cCcEC913420A21e4D11b2DCd3C");
            // console.log(await metamorphicContractFactory.getTransientContractInitializationCode())


            const tnx1 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContractWithConstructor("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000001",Metapod.bytecode)
            // const tnx2 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContract("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000002",Metapod.bytecode,"0x")
            const m = (await tnx1.wait()).events[0].args;
            const deployedAdd = await hre.ethers.getContractAt("Metapod", m.metamorphicContract)
            // console.log(deployedAdd.)

            const metaPodUpdatedDeployTnx2 = await deployedAdd.destroy("0x00");
            const metaPodUpdatedDeployTnx5 = await deployedAdd.deploy("0x00", "0x608060405234801561001057600080fd5b5060f68061001f6000396000f3fe730165878a594ca255338adfa4d48449f69242eb8f331860305773f0da4a0ba5cf57d095da076857e44fe0bc1ece2fff5b6080604052348015604057600080fd5b5060043610606d5760003560e01c80638129fc1c14607257806383197ef014607a578063f8a8fd6d146082575b600080fd5b6078609e565b005b604f60a8565b005b608860c1565b6040518082815260200191505060405180910390f35b6001600081905550565b3373ffffffffffffffffffffffffffffffffffffffff16ff5b6000805490509056fea165627a7a723058204f4a1d6ef6ed8cb7999e54c18b69ad015bebce041aad75ba2e67f077401626580029");

            // await attachedContractOne.test()


            const ContractOne = await hre.ethers.getContractFactory("ContractOne", deployer);

            const deployContractOne = await metamorphicContractFactory.connect(deployer).deployMetamorphicContractWithConstructor("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000003",ContractOne.bytecode)
            // const one = await deployContractOne.wait();
            const deployContractOneReceipt = await deployContractOne.wait();
            console.log(await deployContractOneReceipt.events[0].args)
            const metamorphicContractOne = await deployContractOneReceipt.events[0].args.metamorphicContract
            const attachedContractOne = await hre.ethers.getContractAt("ContractOne", metamorphicContractOne)
            const a =await attachedContractOne.initialize()
            await a.wait()
            // console.log(await attachedContractOne.test())
            // const m = (await deployContractOne.wait()).events[0].args;
            // console.log(m)
            // console.log(deployContractOne)
            // console.log(deployContractOneReceipt)
            const provider = new hre.ethers.providers.JsonRpcProvider('https://eth-mainnet.g.alchemy.com/v2/q-XcEiXre1I0WRwgny8MxxsJN_Tl-GpV');

            const storage = await provider.getStorageAt(
                '0x00000000e82eb0431756271F0d00CFB143685e7B', // contract address
                0// storage index
            );
            const storage1 = await provider.getStorageAt(
                    '0x00000000e82eb0431756271F0d00CFB143685e7B', // contract address
                storage // storage index
            );

            // console.log((storage1));

            const code = await provider.getCode(
                "0x00000000e82eb0431756271F0d00CFB143685e7B",
                "latest"
            );
            // const contract = await tnx1.wait();
            // console.log(deployer.address)
            // hre.ethers.provider.getStorageAt("",3)
            // console.log(tnx1.events[0].arg)



        })

    })
})

function getFinalByteCode(requiredPrelude, ContractOneInstance) {
    const prelude = Buffer.from(requiredPrelude.slice(2), 'hex').toString("hex")
    let ret = "";
    // console.log(" Step 01 :" +  ret)
    ret += (ContractOneInstance.bytecode.substring(0,ContractOneInstance.bytecode.indexOf("60c5")));
    // console.log(" Step 02 :" +  ret)
    ret +=(61);
    // console.log(" Step 03 :" +  ret)
    ret +=("0" + (prelude.length +  parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16) ).toString(16));
    console.log(" Step 04 :" +  ret)
    // console.log((prelude.length + parseInt((ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 2,ContractOneInstance.bytecode.indexOf("60c5") + 4)), 16)));
    // ret +=(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 4 , ContractOneInstance.bytecode.indexOf("6080604052", 12) ));
    ret += "80610020"
    ret +=(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("60c5") + 12 , ContractOneInstance.bytecode.indexOf("6080604052", 12) ));
    console.log(" Step 05 :" +  ret)
    ret +=(prelude);
    // console.log(" Step 06 :" +  ret)
    ret +=(ContractOneInstance.bytecode.substring(ContractOneInstance.bytecode.indexOf("6080604052", 12) ));
    // console.log(" Step 07 :" +  ret)
    return ret;
}