// SPDX-License-Identifier: GPL-3
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Poetry is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _poemIds;
    Counters.Counter private _poemsSold;
    uint256 listingFee = 0.01 ether;

    struct Poem {
        uint256 poemId;
        string poemText;
        address payable author;
        uint256 price; // Price of 0 means not for sale
        bool approved;
    }

    event PoemListedSuccess(
        uint256 indexed poemId,
        string poemText,
        address author,
        uint256 price,
        bool approved
    );

    mapping(uint256 => Poem) private idToPoem;

    constructor() ERC721("Poetry", "POEM") {}

    function createPoem(
        string memory poemText,
        uint256 price
    ) public payable returns (uint256) {
        uint256 newPoemId = _poemIds.current();
        _poemIds.increment();
        _safeMint(msg.sender, newPoemId);
        createListedPoem(newPoemId, poemText, price);
        return newPoemId;
    }

    function createListedPoem(
        uint256 poemId,
        string memory poemText,
        uint256 price
    ) private {
        idToPoem[poemId] = Poem(
            poemId,
            poemText,
            payable(msg.sender),
            price,
            false
        );

        emit PoemListedSuccess(poemId, poemText, msg.sender, price, false);
    }

    function getAllPoems() public view returns (Poem[] memory) {
        uint256 poemCount = _poemIds.current();
        Poem[] memory poems = new Poem[](poemCount);
        uint256 currentIndex = 0;
        for (uint i = 0; i < poemCount; i++) {
            uint256 currentId = i + 1;
            Poem storage currentPoem = idToPoem[currentId];
            poems[currentIndex] = currentPoem;
            currentIndex++;
        }
        return poems;
    }

    function getPoemsByAddress(
        address addr
    ) public view returns (Poem[] memory) {
        uint256 balance = balanceOf(addr);
        Poem[] memory poems = new Poem[](balance);
        for (uint256 i = 0; i < balance; i++) {
            Poem memory poem = idToPoem[tokenOfOwnerByIndex(addr, i)];
            poems[i] = poem;
            i++;
        }
        return poems;
    }

    function setPrice(uint256 poemId, uint256 price) public {
        require(
            ownerOf(poemId) == msg.sender,
            "Only the owner can set the price."
        );
        idToPoem[poemId].price = price;
    }

    function executeSale(uint256 poemId) public payable {
        require(
            idToPoem[poemId].approved,
            "This poem is not approved for sale."
        );
        require(idToPoem[poemId].price > 0, "This poem is not for sale.");
        uint256 price = idToPoem[poemId].price;
        require(msg.value == price, "Price did not match asking price.");

        address originalOwner = ownerOf(poemId);
        _transfer(originalOwner, msg.sender, poemId);
        approve(address(this), poemId);

        payable(owner()).transfer(listingFee);
        payable(originalOwner).transfer(msg.value - listingFee);
    }

    function updateListingFee(uint256 _listingFee) public payable onlyOwner {
        listingFee = _listingFee;
    }

    function getListingFee() public view returns (uint256) {
        return listingFee;
    }

    function approvePoem(uint256 poemId) public onlyOwner {
        idToPoem[poemId].approved = true;
    }

    function getLatestPoem() public view returns (Poem memory) {
        return idToPoem[_poemIds.current() - 1];
    }

    function getPoemById(uint256 poemId) public view returns (Poem memory) {
        return idToPoem[poemId];
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
