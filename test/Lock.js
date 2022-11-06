const { expect } = require("chai");
const { ethers } = require("hardhat");
require("@nomiclabs/hardhat-ethers");

describe("NFTMarket", function () {
  it("Should create and execute marketsale", async function () {
    //Deploying NFTMarket contract
    const Market = await ethers.getContractFactory("NFTMarket");
    const market = await Market.deploy();
    await market.deployed();
    const marketAddress = market.address;

    //Deploying NFT Contract
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(marketAddress);
    await nft.deployed();
    const nftContractAddress = nft.address;

    let listingPrice = await market.getListingPrice();
    listingPrice = listingPrice.toString();

    const auctionPrice = ethers.utils.parseUnits("100", "ether");

    await nft.createToken("http://www.mytokenlocatiom.com");
    await nft.createToken("http://www.mytokenlocatiom2.com");

    //Creating 2 test nfts
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {
      value: listingPrice,
    });
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {
      value: listingPrice,
    });

    const [_, buyerAddress] = await ethers.getSigners();

    await market
      .connect(buyerAddress)
      .createMarketSale(nftContractAddress, 1, { value: auctionPrice });

    //fetch market items
    let items = await market.fetchMarketItems();

    items = await Promise.all(
      items.map(async (i) => {
        const tokenUri = await nft.tokenURI(i.tokenId);

        let item = {
          price: i.price.toString(),
          tokenId: i.tokenId.toString(),
          seller: i.seller,
          owner: i.owner,
          tokenUri,
        };
        return item;
      })
    );

    console.log("items: ", items);
  });
});
