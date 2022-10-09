import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
  const unlockTime = currentTimestampInSeconds + ONE_YEAR_IN_SECS;

  const lockedAmount = ethers.utils.parseEther("1");

  // const L3ndContract = await ethers.getContractFactory("L3ndRegistry");
  // const l3nd = await L3ndContract.deploy(unlockTime, { value: lockedAmount });

  const L3ndContract = await ethers.getContractFactory("L3ND");
  const l3nd = await L3ndContract.deploy();
  await l3nd.deployed();

  console.log('l3nd deployed', l3nd.address);
  

  const L3ndRegistry = await ethers.getContractFactory("L3ndRegistry");
  const registry = await L3ndRegistry.deploy({lend_addr: l3nd.address});
  await registry.deployed();

  console.log('registry deployed', registry.address);

  const LoanFactory = await ethers.getContractFactory("LoanFactory");
  const factoria = await LoanFactory.deploy(l3nd.address, registry.address);
  await factoria.deployed();

  console.log('factoria deployed', factoria.address);


  const TestNFT = await ethers.getContractFactory("TestNFT");
  const nft = await TestNFT.deploy();
  await nft.deployed();

  console.log('test nft deployed', nft.address);

  // Add test nft to whitelist
  let resp = await registry.addToWhitelist(
    nft.address,
    4200000000000000,
    30, 
    1000000000000
  )

  console.log('addedToWhitelist resp:', resp);
  

  // Check get amount to lend
  let toLend = await registry.getAmountToLend(
    nft.address
  )

  console.log('addedToWhitelist toLend:', resp);
  
  
  const [owner,  feeCollector, operator] = await ethers.getSigners();

  // Stake (Add to lending pool)
  await owner.sendTransaction({
    to: l3nd.address,
    value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
  });


  // Mint test NFT
  await nft.safeMint(
    owner.address
  )

  console.log('wl nft minted, will transfer');
  

  // Transfer Whitelisted NFT to main L3nd contract
  // (Ask for loan)
  await nft.safeTransfer(
    owner.address,
    l3nd.address,
    0
  )

  console.log('wl nft transfered');

  console.log(`Lock with 1 ETH and unlock timestamp ${unlockTime} deployed to ${lock.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
