<script lang="ts">
    import { Framework } from "@superfluid-finance/sdk-core";
    import { ethers } from "ethers";
    import { Alchemy, Network } from "alchemy-sdk";

    const config = {
    apiKey: "i7gthpZXJbF5Y6mbm2VF10slqmNorgTd",
    network: Network.ETH_MAINNET,
    };

    const alchemy = new Alchemy(config);

    let mysf;
    let myAccount;
    let myFlowRate;
    let flowRateDisplay;
    let maticxBalance = false;
    let mySigner;
    let myProvider;

    const maticx_address = "0x3aD736904E9e65189c3000c7DD2c8AC8bB7cD4e3"

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

    const handleFlowRateChange = (e) => {
        myFlowRate = e.target.value;
        let newFlowRateDisplay = calculateFlowRate(e.target.value);
        flowRateDisplay = newFlowRateDisplay.toString();
    };

    const fetchNFTs = async () => {

        try {
        const nfts = await alchemy.nft.getNftsForOwner(myAccount);
            return nfts
        } catch (error) {
        console.log(error);
        }
        };
</script>

{#if myAccount}
    <button class="btn" on:click={() => {myAccount = false}}> Log out </button>
{/if}

{#if maticxBalance}
<p><code>Balance: {maticxBalance}</code></p>
{/if}

{#if !myAccount}
    <button class="btn" on:click={connectWallet}> Log in </button>
{/if}
