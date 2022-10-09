<script lang="ts">
    import { Framework } from "@superfluid-finance/sdk-core";
    import { ethers } from "ethers";
    import { Alchemy, Network } from "alchemy-sdk";
    import { abi_registry } from "../utils/compile.js";
	import { onMount } from 'svelte';
	// import Select from './Select.svelte';
	// let formData = {};
	
	// onMount(() => {
	// 	formData.age = 5;
	// 	formData.color = "red";
	// 	formData.color_html = "yellow"
	// });

    const config = {
    apiKey: "i7gthpZXJbF5Y6mbm2VF10slqmNorgTd",
    network: Network.ETH_MAINNET,
    };

    const model_data = {
    "ownedNfts": [
    {
        "contract": {
        "address": "0x0beed7099af7514ccedf642cfea435731176fb02"
        },
        "id": {
        "tokenId": "28",
        "tokenMetadata": {
            "tokenType": "ERC721"
        }
        },
        "title": "DuskBreaker #28",
        "description": "Breakers have the honor of serving humanity through their work on The Dusk. They are part of a select squad of 10,000 recruits who spend their days exploring a mysterious alien spaceship filled with friends, foes, and otherworldly technology.",
        "tokenUri": {
        "raw": "https://duskbreakers.gg/api/breakers/28",
        "gateway": "https://duskbreakers.gg/api/breakers/28"
        },
        "media": [
        {
            "raw": "https://duskbreakers.gg/breaker_images/28.png",
            "gateway": "https://duskbreakers.gg/breaker_images/28.png"
        }
        ],
        "metadata": {
        "name": "DuskBreaker #28",
        "description": "Breakers have the honor of serving humanity through their work on The Dusk. They are part of a select squad of 10,000 recruits who spend their days exploring a mysterious alien spaceship filled with friends, foes, and otherworldly technology.",
        "image": "https://duskbreakers.gg/breaker_images/28.png",
        "external_url": "https://duskbreakers.gg",
        "attributes": [
            {
            "value": "Locust Rider Armor (Red)",
            "trait_type": "Clothes"
            },
            {
            "value": "Big Smile (Purple)",
            "trait_type": "Mouth"
            },
            {
            "value": "Yellow",
            "trait_type": "Background"
            }
        ]
        },
        "timeLastUpdated": "2022-02-16T22:52:54.719Z",
        "contractMetadata": {
        "name": "DuskBreakers",
        "symbol": "DUSK",
        "totalSupply": "10000",
        "tokenType": "ERC721"
        }
    },
    {
        "contract": {
        "address": "0x97597002980134bea46250aa0510c9b90d87a587"
        },
        "id": {
        "tokenId": "5527",
        "tokenMetadata": {
            "tokenType": "ERC721"
        }
        },
        "title": "Runner #5527",
        "description": "Chain Runners are Mega City renegades 100% generated on chain.",
        "tokenUri": {
        "raw": "https://api.chainrunners.xyz/tokens/metadata/5527?dna=73247164192459371523281785218958151913554625578441142916970699984935810987041",
        "gateway": "https://api.chainrunners.xyz/tokens/metadata/5527?dna=73247164192459371523281785218958151913554625578441142916970699984935810987041"
        },
        "media": [
        {
            "raw": "https://img.chainrunners.xyz/api/v1/tokens/png/5527",
            "gateway": "https://img.chainrunners.xyz/api/v1/tokens/png/5527"
        }
        ],
        "metadata": {
        "name": "Runner #5527",
        "description": "Chain Runners are Mega City renegades 100% generated on chain.",
        "image": "https://img.chainrunners.xyz/api/v1/tokens/png/5527",
        "attributes": [
            {
            "value": "Purple Green Diag",
            "trait_type": "Background"
            },
            {
            "value": "Human",
            "trait_type": "Race"
            },
            {
            "value": "Cig",
            "trait_type": "Mouth Accessory"
            }
        ]
        },
        "timeLastUpdated": "2022-02-18T00:42:04.401Z",
        "contractMetadata": {
        "name": "Chain Runners",
        "symbol": "RUN",
        "totalSupply": "10000",
        "tokenType": "ERC721"
        }
    },
    // {},
    // {},
    // {},{},{},
    // {}
    ],
    "totalCount": 6,
    "blockHash": "0xeb2d26af5b6175344a14091777535a2cb21c681665a734a8285f889981987630"
    }

    const alchemy = new Alchemy(config);

    let queryString
    let myAccount;
    try {
        queryString = window.location.search;
        console.log('have q', queryString);
    } catch (error) {
        console.error('failed getting q', error);
    }
    console.log(queryString);
    const urlParams = new URLSearchParams(queryString);
    myAccount = urlParams.get('address')
    console.log(myAccount);

    let mysf;
    let myFlowRate;
    let flowRateDisplay;
    let maticxBalance = false;
    let mySigner;
    let myProvider;
    let userNfts:any = false;
    let amount_to_lend = false;

    const maticx_address = "0xe802A48c76a35A71e3c96EE85b0847666dad8279"

    //where the Superfluid logic takes place
    async function createNewFlow(recipient, flowRate) {
        const chainId = await window.ethereum.request({
            method: "eth_chainId",
        });
        
        console.log("chainId:", chainId);

        const MATICxContract = await mysf.loadSuperToken("fMATICx");
        const MATICx = MATICxContract.address;
        const L3NDContract = "0x";

        try {
            const createFlowOperation = sf.cfaV1.createFlow({
                receiver: recipient,
                flowRate: flowRate,
                superToken: MATICx,
                // userData?: string
            });

            console.log("Creating your stream...");

            const result = await createFlowOperation.exec(signer);
            console.log(result);

            console.log(
                `Congrats - you've just created a money stream!
    View Your Stream At: https://app.superfluid.finance/dashboard/${recipient}
    Network: Kovan
    Super Token: DAIx
    Sender: 0xDCB45e4f6762C3D7C61a00e96Fb94ADb7Cf27721
    Receiver: ${recipient},
    FlowRate: ${flowRate}
    `
            );
        } catch (error) {
            console.log(
                "Hmmm, your transaction threw an error. Make sure that this stream does not already exist, and that you've entered a valid Ethereum address!"
            );
            console.error(error);
        }
    }

    async function connectWallet() {
        try {
            const { ethereum } = window;

            if (!ethereum) {
                alert("Get MetaMask!");
                return;
            }
            const accounts = await ethereum.request({
                method: "eth_requestAccounts",
            });
            console.log("Connected", accounts[0]);
            myAccount = accounts[0];
            // let account = currentAccount;
            // Setup listener! This is for the case where a user comes to our site
            // and connected their wallet for the first time.
            // setupEventListener()

            let chain = await window.ethereum.request({ method: "eth_chainId" });
            let chainId = chain;
            console.log("chain ID:", chain);
            console.log("global Chain Id:", chainId);
            if (chainId != '0x89') {

                await window.ethereum.request({
                method: "wallet_addEthereumChain",
                params: [{
                    chainId: "0x89",
                    rpcUrls: ["https://polygon-rpc.com/"],
                    chainName: "Polygon Mainnet",
                    nativeCurrency: {
                        name: "MATIC",
                        symbol: "MATIC",
                        decimals: 18
                    },
                    blockExplorerUrls: ["https://polygonscan.com/"]
                }]
                });
                chain = await window.ethereum.request({ method: "eth_chainId" });
                chainId = chain;                
            }

            myProvider = new ethers.providers.Web3Provider(window.ethereum);
            mySigner = myProvider.getSigner();


            mysf = await Framework.create({
                chainId: Number(chainId),
                provider: myProvider,
            });
            
            checkBalance()
        } catch (error) {
            console.log(error);
        }
    }

    
    async function checkBalance() {
        console.log('myProvider', myProvider);
        console.log('mySigner', mySigner)
        
        const maticx = await mysf.loadSuperToken(maticx_address);
        maticxBalance = await maticx.balanceOf({
            account: myAccount,
            providerOrSigner: myProvider
        });
        console.log('maticx balance:', maticxBalance);
    }

    const checkIfWalletIsConnected = async () => {
        const { ethereum } = window;

        if (!ethereum) {
            console.log("Make sure you have metamask!");
            return;
        } else {
            console.log("We have the ethereum object", ethereum);
        }

        const accounts = await ethereum.request({ method: "eth_accounts" });
        const chain = await window.ethereum.request({ method: "eth_chainId" });
        let chainId = chain;
        console.log("chain ID:", chain);
        console.log("global Chain Id:", chainId);
        if (accounts.length !== 0) {
            const account = accounts[0];
            console.log("Found an authorized account:", account);
            myAccount = account;
            // Setup listener! This is for the case where a user comes to our site
            // and ALREADY had their wallet connected + authorized.
            // setupEventListener()
        } else {
            console.log("No authorized account found");
        }
    };

    function calculateFlowRate(amount) {
        if (
            typeof Number(amount) !== "number" ||
            isNaN(Number(amount)) === true
        ) {
            alert("You can only calculate a flowRate based on a number");
            return;
        } else if (typeof Number(amount) === "number") {
            if (Number(amount) === 0) {
                return 0;
            }
            const amountInWei = ethers.BigNumber.from(amount);
            const monthlyAmount = ethers.utils.formatEther(
                amountInWei.toString()
            );
            console.log('monthlyAmount', monthlyAmount);
            const calculatedFlowRate: number = monthlyAmount * 3600 * 24 * 30;
            return calculatedFlowRate;
        }
    }

    function getAmountToLend(token_address) {
        const GOV = new ethers.Contract(maticx_address, abi_registry, mySigner);

        amount_to_lend =  GOV.getAmountToLend(token_address);


        return amount_to_lend
        
    }

    const handleFlowRateChange = (e) => {
        myFlowRate = e.target.value;
        let newFlowRateDisplay = calculateFlowRate(e.target.value);
        flowRateDisplay = newFlowRateDisplay.toString();
    }
    
    function fetchNFTs() {
        try {
        // const nfts = await alchemy.nft.getNftsForOwner(myAccount);
            const nfts = model_data.ownedNfts
            console.log(nfts)
            return nfts
        } catch (error) {
        console.log(error);
        }
    };

    let nft_address;
    function selectNft(address) {
        console.log("nft selected", address)
        nft_address = address
    };

    userNfts = fetchNFTs()
</script>

<link rel="stylesheet" href="src/styles/global.css">

<!-- {#if myAccount}
    <button class="btn" on:click={() => {myAccount = false}}> Log out </button>
{/if} -->

    <!-- {#if maticxBalance}
    <p><code>Balance: {maticxBalance}</code></p>
    {/if} -->

<!-- {#if !myAccount} -->
<div width="50%">
    <button class="btn wallet-connected-box" on:click={connectWallet} style=""><p class="wallet-connected-text">{myAccount}</p></button>
</div>
<!-- {/if} -->

<!-- <div>
    {#each userNfts as nft}
        {nft.address}
    {/each}
</div> -->

<div class="side-popup">

</div>

<div>
    <button class="ask-loan-button" on:click={selectNft(nft.contract.address)}>
        <p class="black-button-text">
            L3ND
        </p>
    </button>
    <div class="nfts-box">
        {#if myAccount}
            {#if userNfts}
                {#each userNfts as nft}
                <div class="nft-box">
                    <button style="width:100%" on:click={selectNft(nft.contract.address)}>
                    <img src={nft.metadata.image} alt=""  class="nft-image">
                    <p class="nft-title">
                        {nft.metadata.name}
                    </p>

                    
                <!-- </div>
                    <button style="height:300px; width:190px; background:red">
                        hola
                    </button>
                    <div style="height:300px; width:190px; background:red"> 
                        nft  -->
                    </button>
                    </div>
                
                {/each}
            {/if} 
        {/if} 
    </div>
</div>


<style>
    .side-popup {
        position: absolute;
        width: 445px;
        height: 961px;
        left: 971px;
        top: 42px;

        background: #131C2A;
        box-shadow: 0px 4px 34px rgba(6, 21, 45, 0.3);
        border-radius: 10px;
    }
    .ask-loan-button {
        position: absolute;
        width: 195px;
        height: 74px;
        left: 345px;
        top: 541px;

        background: #68F0B0;
        border-radius: 3px;
        border:0px
    }
    .nft-image {
        width: inherit;
    }
    .nft-title {
        font-family: 'Chakra Petch';
    font-style: normal;
    font-weight: 700;
    font-size: 22px;
    line-height: 29px;
    margin: 0px;

    padding-left: 20px;
    padding-right: 20px;
    }
    .wallet-connect {
        position: absolute;
        width: 269px;
        height: 55px;
        left: 120px;
        top: 655px;

        background: #65F2C0;
        border-radius: 3px;
        border:0
    }
    .black-button-text {
        /* position: absolute; */
        /* width: 166px;
        height: 27px;
        left: 167px;
        top: 669px; */

        font-family: 'Inter';
        font-style: normal;
        font-weight: 700;
        font-size: 22px;
        line-height: 27px;
        margin: 0px;
        /* identical to box height */

        color: #131C2A;

    }
    .wallet-connected-box {
        box-sizing: border-box;

        position: absolute;
        width: 108px;
        height: 32px;
        left: 1650px;
        top: 50px;

        border: 2px solid #131C2A;
        border-radius: 3px;
    }
    .wallet-connected-text {
        font-family: 'Inter';
        font-style: normal;
        font-weight: 500;
        font-size: 16px;
        line-height: 19px;
        text-align: center;
        margin: 0px;

        text-overflow: ellipsis;
        white-space: nowrap;
        overflow: hidden;

        color: #131C2A;

    }
    .nft-grid {
        left: 0;
        height: 100%
    }
    .nft-box {
        /* position: absolute; */
        width: 190px;
        height: 330px;
        /* left: 891px;
        top: 162px; */

        background: #FFFFFF;
        box-shadow: 0px 4px 25px rgba(0, 0, 0, 0.1);
        border-radius: 3px;
        margin: 50px;
    }
    .nfts-box {
        display: flex;
        width: 55%;
        height: 100%;
        right: 0;
        position: absolute;
        padding: 50px;
        flex-wrap: wrap;
    }
</style>