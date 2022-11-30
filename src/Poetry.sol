// SPDX-License-Identifier: GPL-3
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Poetry is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _poemIds;
    Counters.Counter private _poemsSold;
    uint256 listingFee = 0.01 ether;

    struct Poem {
        uint256 poemId;
        string poemText;
        address payable owner;
        address payable seller;
        address payable author;
        uint256 price;
        bool currentlyListed;
        bool approved;
    }

    event PoemListedSuccess(
        uint256 indexed poemId,
        string poemText,
        address owner,
        address seller,
        address author,
        uint256 price,
        bool currentlyListed,
        bool approved
    );

    mapping(uint256 => Poem) private idToPoem;

    constructor() ERC721("Poetry", "POEM") {}

    function createPoem(
        string memory poemText,
        uint256 price
    ) public payable returns (uint256) {
        _poemIds.increment();
        uint256 newPoemId = _poemIds.current();
        _safeMint(msg.sender, newPoemId);
        createListedPoem(newPoemId, poemText, price);
        return newPoemId;
    }

    function createListedPoem(
        uint256 poemId,
        string memory poemText,
        uint256 price
    ) private {
        //require(msg.value == listingFee);
        require(price > 0);
        idToPoem[poemId] = Poem(
            poemId,
            poemText,
            payable(address(this)),
            payable(msg.sender),
            payable(msg.sender),
            price,
            true,
            false
        );

        _transfer(msg.sender, address(this), poemId);

        emit PoemListedSuccess(
            poemId,
            poemText,
            address(this),
            msg.sender,
            msg.sender,
            price,
            true,
            false
        );
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

    function getMyPoems() public view returns (Poem[] memory) {
        // First get the number of poems owned.
        uint256 totalPoemCount = _poemIds.current();
        uint256 poemCount = 0;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalPoemCount; i++) {
            if (
                idToPoem[i + 1].owner == msg.sender ||
                idToPoem[i + 1].seller == msg.sender
            ) {
                poemCount++;
            }
        }
        return _getPoemsByAddress(msg.sender, poemCount);
    }

    function _getPoemsByAddress(
        address addr,
        uint256 n
    ) private view returns (Poem[] memory) {
        uint256 currentIndex = 0;
        Poem[] memory poems = new Poem[](n);
        for (uint256 i = 0; i < n; i++) {
            if (
                idToPoem[i + 1].owner == addr || idToPoem[i + 1].seller == addr
            ) {
                uint256 currentId = i + 1;
                Poem storage currentPoem = idToPoem[currentId];
                poems[currentIndex] = currentPoem;
                currentIndex++;
            }
        }
        return poems;
    }

    function executeSale(uint256 poemId) public payable {
        require(
            idToPoem[poemId].approved,
            "This poem is not approved for sale."
        );
        uint256 price = idToPoem[poemId].price;
        address seller = idToPoem[poemId].seller;
        require(msg.value == price, "Price did not match asking price.");

        _transfer(address(this), msg.sender, poemId);
        approve(address(this), poemId);

        payable(owner()).transfer(listingFee);
        payable(seller).transfer(msg.value);
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
        return idToPoem[_poemIds.current()];
    }

    function getPoemById(uint256 poemId) public view returns (Poem memory) {
        return idToPoem[poemId];
    }

    function getPoemCount() public view returns (uint256) {
        return _poemIds.current();
    }
}
