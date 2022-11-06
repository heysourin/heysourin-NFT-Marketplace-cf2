// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;// Another file importing this file will not have access to this

    //Address of nftmarketplace
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Complete Web 3","CW3"){
        contractAddress = marketplaceAddress;
    }

    function createToken(string memory tokenURI) public returns(uint){
        _tokenIds.increment();
        uint newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);// Genarate the URI
        setApprovalForAll(contractAddress,true);// Grant transaction permission to marketplace

        return newItemId;
    }

}
