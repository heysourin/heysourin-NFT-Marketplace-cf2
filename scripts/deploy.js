const hre = require("hardhat");

async function main() {
  const NFTMarket = await hre.ethers.getContractFactory("NFTMarket");
  const nftmarket = await NFTMarket.deploy();
  await nftmarket.deployed();
  const nftMarketAddress = nftmarket.address;

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nftMarketAddress);
  await nft.deployed();

  console.log(`NFTMarket Contract deployed to ${nftmarket.address}`);//0xd8d98Cb76768F81b0F506a54149df3538011eAe5
  console.log(`NFT Contract deployed to ${nft.address}`);//0x184697914f5cE976aB8f9F90E01236E60E50F146
}


main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
