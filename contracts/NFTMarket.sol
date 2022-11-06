//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; //prevents re-entrancy attacks

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner; //Contract owner, will receive commission
    uint listingPrice = 0.0025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    struct MarketItem {
        uint itemId;
        address nftContract;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool sold;
    }

    mapping(uint => MarketItem) private idMarketItem;

    event MarketItemCreated(
        uint indexed itemId,
        address indexed nftContract,
        uint indexed tokenId,
        address seller,
        address owner,
        uint price,
        bool sold
    );

    function getListingPrice() public view returns (uint) {
        return listingPrice;
    }

    function setListingPrice(uint _price) public returns (uint) {
        if (msg.sender == address(this)) {
            listingPrice = _price;
        }
        return listingPrice;
    }

    //Function to create market item
    function createMarketItem(
        address nftContract,
        uint tokenId,
        uint price
    ) public payable nonReentrant {
        require(price > 0, "Price can't be zero");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        _itemIds.increment();
        uint itemId = _itemIds.current();

        idMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender), // Seller, putting the nft for sell
            payable(address(0)), //No owner yet
            price,
            false
        );

        /// @dev Transferring nft ownership to the contract for this time being
        /// @param address of the nft contract from function input
        IERC721(nftContract).transferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        emit MarketItemCreated(
            itemId,
            nftContract,
            tokenId,
            msg.sender,
            address(0),
            price,
            false
        );
    }

    // Function to create a sale
    function createMarketSale(address nftContract, uint itemId)
        public
        payable
        nonReentrant
    {
        uint price = idMarketItem[itemId].price;
        uint tokenId = idMarketItem[itemId].tokenId;

        require(
            msg.value == price,
            "Please pay the exact price in order to complete the purchase"
        );

        //Pay the seller the amount
        idMarketItem[itemId].seller.transfer(msg.value);

        /// @dev Transferring nft ownership from the contract to the buyer
        IERC721(nftContract).transferFrom(
            address(this),
            msg.sender,
            tokenId
        );

        idMarketItem[itemId].owner = payable(msg.sender); //Marking buyer as the new owner
        idMarketItem[itemId].sold = true; //Marked as sold

        _itemsSold.increment();

        payable(owner).transfer(listingPrice); // Transferred to the contract owner
    }

    /// @notice Total number of unsold items on our site
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint itemCount = _itemIds.current(); // Total mumber of items created on our platform
        uint unsoldItemCount = itemCount - _itemsSold.current();

        uint currentIndex = 0;
        MarketItem[] memory items = new MarketItem[](unsoldItemCount); //Creating an array of MarketItem, MarketItem is a working as a data type right now

        //loop through all items ever created
        for (uint i = 0; i < itemCount; i++) {
            //get only unsold item
            //check if the item has not been sold
            //by checking if the owner field is empty
            if (idMarketItem[i + 1].owner == address(0)) {
                //yes, this item has never been sold
                uint currentId = idMarketItem[i + 1].itemId; //Accessing using mapping and struct
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items; //return array of all unsold items
    }

    /// @notice fetching nfts owned/ bought by this user
    function fetchMmyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemsCount = _itemIds.current();
        uint itemCount = 0;

        uint currentIndex = 0;

        for (uint i = 0; i < totalItemsCount; i++) {
            //Getting the items belongs to msg.sender(owned or bought)
            if (idMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1; // Total length
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemsCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                uint currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint totalItemsCount = _itemIds.current();
        uint itemCount = 0;

        uint currentIndex = 0;

        for (uint i = 0; i < totalItemsCount; i++) {
            //Getting the items belongs to msg.sender(owned or bought)
            //Seller is the one who is currently loggedin
            if (idMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1; // Total length
            }
        }

        MarketItem[] memory items = new MarketItem[](itemCount);
        for (uint i = 0; i < totalItemsCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                uint currentId = idMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
