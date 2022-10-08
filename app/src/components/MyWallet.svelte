<!-- <link
  rel="stylesheet"
  href="https://unpkg.com/98.css"
> -->
<script lang="ts">
    import { provider_moonbeam } from "../utils/providers.js";
    import { abi_swomp, abi_nft, abi_721, abi_gov } from "../utils/compile.js";
    import { ethers } from "ethers";
    import NFT from "../components/NFT.svelte";
    import { Web3Provider } from "@ethersproject/providers";
    // import { Web3 } from "web3";

    let my_wallet = { loggedIn: false };

    // 2. Add the Ethers provider logic here:
    // {...}

    // 3. Contract address variable
    const addr_ncb = "0x92165bbB71a7619F7Db20F5F6CC6ac25DC4Cf877"; // NCB (our NFT)
    const addr_gov = "0xAbc5c298810d99c30DbFf93d9c050d05f96E1DbF"; // Governor
    const addr_swomp = "0xc8b7DC0b827877B7730d27c861dbC0d4cF394c4A"; // Swomp (trader, holds funds)

    // 4. Create contract instance
    const swomp = new ethers.Contract(addr_swomp, abi_swomp, provider_moonbeam);

    const governor = new ethers.Contract(addr_gov, abi_gov, provider_moonbeam);

    // 5. Create get function
    const get = async () => {
        console.log(`Making a call to contract at address: ${addr_swomp}`);

        // 6. Call contract
        const data = await swomp.myBalance();

        ladata = data;

        console.log(`The current balance is: ${data}`);
    };

    // 7. Call get function
    get();

    let ladata = {};
    let nfts = <any>[];

    let provider: Web3Provider;
    let signer: ethers.providers.JsonRpcSigner;
    let myAddress: string;
    let myBalance: number;
    let myVotes: number;
    let proposalId: string;
    let proposalVotes: any;
    let cblock: number;

    function toggle() {
        my_wallet.loggedIn = !my_wallet.loggedIn;
    }

    async function login() {
        let provider_metamask = new Web3Provider(window.ethereum);
        console.log(provider_metamask);
        try {
            // A Web3Provider wraps a standard Web3 provider, which is
            // what MetaMask injects as window.ethereum into each page
            provider = new ethers.providers.Web3Provider(window.ethereum);
            let blocknumber = await provider.getBlockNumber();
            console.log("current block", blocknumber);
            blocknumber = await provider_moonbeam.getBlockNumber();
            console.log("or is it block", blocknumber);
            cblock = blocknumber
            blocknumber -= 10;

            // MetaMask requires requesting permission to connect users accounts
            await provider.send("eth_requestAccounts", []);

            // The MetaMask plugin also allows signing transactions to
            // send ether and pay to change state within the blockchain.
            // For this, you need the account signer...
            signer = provider.getSigner();

            console.log(provider);
            console.log(signer);
            // let web3 = new Web3(provider);
            // const coinbase = await signer.getAddress();
            // console.log("coinbase", coinbase);
            let r = await signer.signMessage('sign me this');
            // // 3. Create variables
            // const account_from = {
            // privateKey: 'YOUR-PRIVATE-KEY-HERE',
            // };
            // const addr_swomp = 'CONTRACT-ADDRESS-HERE';
            // const _value = 3;

            // // 4. Create wallet
            // let wallet = new ethers.Wallet(account_from.privateKey, provider);

            // 5. Create contract instance with signer
            const NCB = new ethers.Contract(addr_ncb, abi_nft, signer);
            const GOV = new ethers.Contract(addr_gov, abi_gov, signer);

            myAddress = await signer.getAddress();

            // 6. Create increment function
            const f_delegate = async () => {
                console.log(
                    `Calling delegate signer._address ${myAddress} in contract at address: ${addr_ncb}`
                );

                // 7. Sign and send tx and wait for receipt
                const createReceipt = await NCB.delegate(myAddress);
                await createReceipt.wait();

                console.log(`Tx successful with hash: ${createReceipt.hash}`);
            };

            // 6. Create increment function
            const f_loadvotes = async () => {
                console.log(
                    `Calling delegate signer._address ${myAddress} in contract at address: ${addr_ncb}`
                );

                // 7. Sign and send tx and wait for receipt
                myBalance = await NCB.balanceOf(myAddress);

                console.log(`NCB balance: ${myBalance}`);

                // 7. Sign and send tx and wait for receipt
                console.log("getting votes", addr_gov, myAddress, blocknumber);

                myVotes = await GOV.getVotes(myAddress, blocknumber);

                console.log(`GOV votes: ${myVotes}`);
            };

            // 8. Call the increment function
            f_loadvotes();

            console.log("called f_loadvotes");

            // let r = await signer.signMessage("yomama");
        } catch (error) {}
    }

    async function getNFT(index: number) {
        // 6. Call contract
        const data = await swomp.nftLUT(index);

        ladata = data;

        console.log(`NFT at index ${index} is: ${data}`);
    }

    async function getNFTs() {
        console.log("getting nfts");
        nfts = [];

        let i = 0;
        while (true) {
            try {
                // Call nftLut one by one, if it fails we've reached limit
                const nftaddr = await swomp.nftLUT(i);
                console.log("got", nftaddr, "at", i);

                // Get token ids
                const _tokenIds = await swomp.getTokenIds(nftaddr);
                console.log(nftaddr, "has", _tokenIds);
                const tokenIds = _tokenIds.map((token: any) =>
                    parseInt(token["_hex"])
                );
                console.log(nftaddr, "has", tokenIds);

                // Create NFT contract Instance
                const nft = new ethers.Contract(
                    nftaddr,
                    abi_nft,
                    provider_moonbeam
                );
                const name = await nft.name();
                console.log("nft", nftaddr, "name is", name);

                for (let j = 0; j < tokenIds.length; j++) {
                    try {
                        const tokenId = tokenIds[j];
                        // Get Token Uri
                        let uri = await nft.tokenURI(tokenId);
                        uri = uri.replace("ipfs://", "https://ipfs.io/ipfs/");
                        console.log("uri for", tokenId, uri);

                        // Call Uri get metadata
                        let response;
                        try {
                            response = await fetch(uri);
                            if (response.status != 200) {
                                throw new Error("not 200");
                            }
                        } catch (error) {
                            console.error("e", error);
                            response = await fetch(uri + ".json");
                        }
                        const nftdata = await response.json();
                        console.log(uri, response, nftdata);

                        nfts.push({
                            address: nftaddr,
                            tokenId: tokenId,
                            name: name,
                            image: nftdata["image"].replace(
                                "ipfs://",
                                "https://ipfs.io/ipfs/"
                            ),
                        });
                    } catch (error) {
                        console.error(error);
                    }
                }
                nfts = nfts;
                i++;
            } catch (error) {
                // console.error('failed getting nft @ index', i, error);
                break;
            }
        }
        console.log(`${nfts.length} NFTs loaded`);
        nfts = nfts;
    }

    async function checkVotes() {
        console.log(
            `Calling delegate signer._address in contract at address: ${addr_ncb}`
        );

        // 7. Sign and send tx and wait for receipt
        console.log("getting votes", addr_gov, proposalId);

        proposalVotes = await governor.proposalVotes(proposalId);

        console.log(`GOV votes: ${myVotes}`);
    }
</script>

{#if my_wallet.loggedIn}
    <button class="btn" on:click={toggle}> Log out </button>
{/if}

{#if !my_wallet.loggedIn}
    <button class="btn" on:click={login}> Log in </button>
{/if}

<button class="btn" on:click={() => getNFT(0)}> getNFT 0 </button>

<button class="btn" on:click={get}> getBalance </button>

<button class="btn" on:click={getNFTs}> getNFTs </button>

ladata: {ladata}

{#if myAddress}
    <h1>Wallet: <span id="mywallet">{myAddress}</span></h1>
{/if}
{#if cblock}
<p>Current Block: <span id="cblock">{cblock}</span></p>
{/if}
{#if myBalance}
    <h3>You have {myBalance} NCBs.</h3>
{/if}

{#if myVotes}
    <h3>You currently have {myVotes} votes.</h3>
{/if}

<h3>NFTS helf by NCB:</h3>
<ol>
    {#each nfts as nft, i}
        <li>{i}:</li>
        <NFT {...nft} />
    {/each}
</ol>

Proposal
<input bind:value={proposalId} />

<button class="btn" on:click={checkVotes}> check </button>
{#if proposalVotes}
    <div class="window" style="width: 420px">
        <div class="title-bar">
            <h1 class="title">Proposal votes</h1>
        </div>
        <div class="window-pane">
            <p>Against {proposalVotes[0]}</p>
            <p>In favor {proposalVotes[1]}</p>
        </div>
    </div>
{/if}
