const hre = require("hardhat");
const fs = require("fs");
// fs.readFileSync("./json/data.json", "utf8");
const contractOneABI =  JSON.parse(fs.readFileSync("./artifacts/contracts/MetamorphicPattern/mock/ContractOne.sol/ContractOne.json", "utf8"));
const contractTwoABI =  JSON.parse(fs.readFileSync("./artifacts/contracts/MetamorphicPattern/mock/ContractTwo.sol/ContractTwo.json", "utf8"));
const contractThreeABI =  JSON.parse(fs.readFileSync("./artifacts/contracts/MetamorphicPattern/mock/ContractThree.sol/ContractThree.json", "utf8"));

describe("",()=> {
    let deployer;
    describe("",()=> {
        before("Before Metamorphic Test", async () => {
            [deployer] = await hre.ethers.getSigners();

        })


        it("",async () => {
            // let immutableCreate2Factory = (await hre.ethers.getContractAt("ImmutableCreate2Factory", "0x000000000063b99B8036c31E91c64fC89bFf9ca7"));
            let metamorphicContractFactory = await (await hre.ethers.getContractFactory("MetamorphicContractFactory")).deploy("0x608060405260603373ffffffffffffffffffffffffffffffffffffffff166357b9f5236040518163ffffffff1660e01b815260040160006040518083038186803b15801561004c57600080fd5b505afa158015610060573d6000803e3d6000fd5b505050506040513d6000823e3d601f19601f82011682018060405250602081101561008a57600080fd5b8101908080516401000000008111156100a257600080fd5b828101905060208101848111156100b857600080fd5b81518560018202830111640100000000821117156100d557600080fd5b505092919050505090506000816020018251808234f092505050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141561012957600080fd5b8073ffffffffffffffffffffffffffffffffffffffff16fffe");
            let Metapod = await hre.ethers.getContractFactory("Metapod");
            // 0x09888Addf726E6B04dBc6bd8BFE5Bf4A924D597F
            const salt = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000002";
            // const salt = "0x09888Addf726E6B04dBc6bd8BFE5Bf4A924D597F000000000000000000000002";

            let tnx1 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContract(salt,contractOneABI.bytecode, "0x")
            let metamorphicContract = (await tnx1.wait()).events[0].args.metamorphicContract
            // let newImplementation = (await tnx1.wait()).events[0].args.newImplementation
            console.log(metamorphicContract);
            // // console.log(newImplementation);
            //
            const attachedContractOne = await hre.ethers.getContractAt("ContractOne", metamorphicContract)
            // const attachedContractOne1 = await hre.ethers.getContractAt("ContractOne", newImplementation)
            const a =await attachedContractOne.initialize()
            await a.wait()
            //
            console.log(await attachedContractOne.test())
            await attachedContractOne.destroy();
            //
            tnx1 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContract(salt,contractTwoABI.bytecode, "0x")
            metamorphicContract = (await tnx1.wait()).events[0].args.metamorphicContract
            newImplementation = (await tnx1.wait()).events[0].args.newImplementation
            console.log(metamorphicContract);
            console.log(newImplementation);
            //
             const attachedContractTwo = await hre.ethers.getContractAt("ContractTwo", metamorphicContract)
            const attachedContractTwo1 = await hre.ethers.getContractAt("ContractTwo", newImplementation)
             const b  =await attachedContractTwo.initialize()
             await b.wait()


            console.log(await attachedContractTwo.test())


            tnx1 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContractWithConstructor(salt,contractThreeABI.bytecode + '0000000000000000000000000000000000000000000000000000000000000009')
            metamorphicContract = (await tnx1.wait()).events[0].args.metamorphicContract
            newImplementation = (await tnx1.wait()).events[0].args.newImplementation
            console.log(metamorphicContract);
            console.log(newImplementation);

            const attachedContractThree = await hre.ethers.getContractAt("ContractThree", metamorphicContract)
            // const attachedContractOne1 = await hre.ethers.getContractAt("ContractOne", newImplementation)
            // const c =await attachedContractThree.initialize()
            // await c.wait()
            //
            console.log(await attachedContractThree.test())
            await attachedContractThree.destroy();
            // await attachedContractOne.destroy();
            // console.log(contractOneABI.bytecode)
            // const tnx1 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContractWithConstructor("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000001",Metapod.bytecode)
            // const tnx2 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContract("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000002",Metapod.bytecode,"0x")
            // const m = (await tnx1.wait()).events[0].args;
            // const deployedAdd = await hre.ethers.getContractAt("Metapod", m.metamorphicContract)
            // // console.log(deployedAdd.)

            // const metaPodUpdatedDeployTnx2 = await deployedAdd.destroy("0x00");
            // const metaPodUpdatedDeployTnx5 = await deployedAdd.deploy("0x00", "0x608060405234801561001057600080fd5b5060f68061001f6000396000f3fe730165878a594ca255338adfa4d48449f69242eb8f331860305773f0da4a0ba5cf57d095da076857e44fe0bc1ece2fff5b6080604052348015604057600080fd5b5060043610606d5760003560e01c80638129fc1c14607257806383197ef014607a578063f8a8fd6d146082575b600080fd5b6078609e565b005b604f60a8565b005b608860c1565b6040518082815260200191505060405180910390f35b6001600081905550565b3373ffffffffffffffffffffffffffffffffffffffff16ff5b6000805490509056fea165627a7a723058204f4a1d6ef6ed8cb7999e54c18b69ad015bebce041aad75ba2e67f077401626580029");

            // await attachedContractOne.test()


            // const ContractOne = await hre.ethers.getContractFactory("ContractOne", deployer);
            //
            // const deployContractOne = await metamorphicContractFactory.connect(deployer).deployMetamorphicContractWithConstructor("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000003",ContractOne.bytecode)
            // // const one = await deployContractOne.wait();
            // const deployContractOneReceipt = await deployContractOne.wait();
            // console.log(await deployContractOneReceipt.events[0].args)
            // const metamorphicContractOne = await deployContractOneReceipt.events[0].args.metamorphicContract
            // const attachedContractOne = await hre.ethers.getContractAt("ContractOne", metamorphicContractOne)
            // const a =await attachedContractOne.initialize()
            // await a.wait()
            // // console.log(await attachedContractOne.test())
            // // const m = (await deployContractOne.wait()).events[0].args;
            // // console.log(m)
            // // console.log(deployContractOne)
            // // console.log(deployContractOneReceipt)
            // const provider = new hre.ethers.providers.JsonRpcProvider('https://eth-mainnet.g.alchemy.com/v2/q-XcEiXre1I0WRwgny8MxxsJN_Tl-GpV');
            //
            // const storage = await provider.getStorageAt(
            //     '0x00000000e82eb0431756271F0d00CFB143685e7B', // contract address
            //     0// storage index
            // );
            // const storage1 = await provider.getStorageAt(
            //     '0x00000000e82eb0431756271F0d00CFB143685e7B', // contract address
            //     storage // storage index
            // );
            //
            // // console.log((storage1));
            //
            // const code = await provider.getCode(
            //     "0x00000000e82eb0431756271F0d00CFB143685e7B",
            //     "latest"
            // );
            // const contract = await tnx1.wait();
            // console.log(deployer.address)
            // hre.ethers.provider.getStorageAt("",3)
            // console.log(tnx1.events[0].arg)



        })

        it.only("",async () => {
            // let immutableCreate2Factory = (await hre.ethers.getContractAt("ImmutableCreate2Factory", "0x000000000063b99B8036c31E91c64fC89bFf9ca7"));
            let metamorphicContractFactory = await (await hre.ethers.getContractFactory("MetamorphicContractFactory")).deploy("0x608060405260603373ffffffffffffffffffffffffffffffffffffffff166357b9f5236040518163ffffffff1660e01b815260040160006040518083038186803b15801561004c57600080fd5b505afa158015610060573d6000803e3d6000fd5b505050506040513d6000823e3d601f19601f82011682018060405250602081101561008a57600080fd5b8101908080516401000000008111156100a257600080fd5b828101905060208101848111156100b857600080fd5b81518560018202830111640100000000821117156100d557600080fd5b505092919050505090506000816020018251808234f092505050600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141561012957600080fd5b8073ffffffffffffffffffffffffffffffffffffffff16fffe");
            // 0x09888Addf726E6B04dBc6bd8BFE5Bf4A924D597F
            const salt = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000002";
            // const salt = "0x09888Addf726E6B04dBc6bd8BFE5Bf4A924D597F000000000000000000000002";



            const tnx1 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContract(salt,contractThreeABI.bytecode + '0000000000000000000000000000000000000000000000000000000000000009',"0x")
            const metamorphicContract = (await tnx1.wait()).events[0].args.metamorphicContract
            const newImplementation = (await tnx1.wait()).events[0].args.newImplementation
            console.log(metamorphicContract);
            console.log(newImplementation);

            const attachedContractThree = await hre.ethers.getContractAt("ContractThree", metamorphicContract)
            // const attachedContractOne1 = await hre.ethers.getContractAt("ContractOne", newImplementation)
            // const c =await attachedContractThree.initialize()
            // await c.wait()
            //
            console.log(await attachedContractThree.test())
            await attachedContractThree.destroy();
            // await attachedContractOne.destroy();
            // console.log(contractOneABI.bytecode)
            // const tnx1 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContractWithConstructor("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000001",Metapod.bytecode)
            // const tnx2 = await metamorphicContractFactory.connect(deployer).deployMetamorphicContract("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000002",Metapod.bytecode,"0x")
            // const m = (await tnx1.wait()).events[0].args;
            // const deployedAdd = await hre.ethers.getContractAt("Metapod", m.metamorphicContract)
            // // console.log(deployedAdd.)

            // const metaPodUpdatedDeployTnx2 = await deployedAdd.destroy("0x00");
            // const metaPodUpdatedDeployTnx5 = await deployedAdd.deploy("0x00", "0x608060405234801561001057600080fd5b5060f68061001f6000396000f3fe730165878a594ca255338adfa4d48449f69242eb8f331860305773f0da4a0ba5cf57d095da076857e44fe0bc1ece2fff5b6080604052348015604057600080fd5b5060043610606d5760003560e01c80638129fc1c14607257806383197ef014607a578063f8a8fd6d146082575b600080fd5b6078609e565b005b604f60a8565b005b608860c1565b6040518082815260200191505060405180910390f35b6001600081905550565b3373ffffffffffffffffffffffffffffffffffffffff16ff5b6000805490509056fea165627a7a723058204f4a1d6ef6ed8cb7999e54c18b69ad015bebce041aad75ba2e67f077401626580029");

            // await attachedContractOne.test()


            // const ContractOne = await hre.ethers.getContractFactory("ContractOne", deployer);
            //
            // const deployContractOne = await metamorphicContractFactory.connect(deployer).deployMetamorphicContractWithConstructor("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266000000000000000000000003",ContractOne.bytecode)
            // // const one = await deployContractOne.wait();
            // const deployContractOneReceipt = await deployContractOne.wait();
            // console.log(await deployContractOneReceipt.events[0].args)
            // const metamorphicContractOne = await deployContractOneReceipt.events[0].args.metamorphicContract
            // const attachedContractOne = await hre.ethers.getContractAt("ContractOne", metamorphicContractOne)
            // const a =await attachedContractOne.initialize()
            // await a.wait()
            // // console.log(await attachedContractOne.test())
            // // const m = (await deployContractOne.wait()).events[0].args;
            // // console.log(m)
            // // console.log(deployContractOne)
            // // console.log(deployContractOneReceipt)
            // const provider = new hre.ethers.providers.JsonRpcProvider('https://eth-mainnet.g.alchemy.com/v2/q-XcEiXre1I0WRwgny8MxxsJN_Tl-GpV');
            //
            // const storage = await provider.getStorageAt(
            //     '0x00000000e82eb0431756271F0d00CFB143685e7B', // contract address
            //     0// storage index
            // );
            // const storage1 = await provider.getStorageAt(
            //     '0x00000000e82eb0431756271F0d00CFB143685e7B', // contract address
            //     storage // storage index
            // );
            //
            // // console.log((storage1));
            //
            // const code = await provider.getCode(
            //     "0x00000000e82eb0431756271F0d00CFB143685e7B",
            //     "latest"
            // );
            // const contract = await tnx1.wait();
            // console.log(deployer.address)
            // hre.ethers.provider.getStorageAt("",3)
            // console.log(tnx1.events[0].arg)



        })

    })
})
