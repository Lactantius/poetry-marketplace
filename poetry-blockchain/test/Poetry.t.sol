// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/Poetry.sol";

contract PoetryTest is Test {
    Poetry public poetry;

    address internal owner = msg.sender;
    address internal constant rando = address(100);
    address internal constant buyer = address(101);

    function setUp() public {
        vm.label(owner, "Owner");
        vm.deal(owner, 10 ether);
        vm.label(rando, "Rando");
        vm.deal(rando, 10 ether);
        vm.label(buyer, "Buyer");
        vm.deal(buyer, 10 ether);
        vm.prank(owner);
        poetry = new Poetry();
        vm.prank(rando);
        poetry.createPoem("Test poem", .1 ether);
    }

    // Listing fees

    function testGetListingFee() public {
        vm.prank(rando);
        assertEq(poetry.getListingFee(), 0.01 ether);
    }

    function testChangeListingFee() public {
        vm.prank(owner);
        poetry.updateListingFee(0.02 ether);
        assertEq(poetry.getListingFee(), 0.02 ether);
    }

    function testFailNonOwnerChangeListingFee() public {
        vm.prank(rando);
        poetry.updateListingFee(0.02 ether);
    }

    // Approvals

    function testApprovePoem() public {
        assertFalse(poetry.getPoemById(1).approved);
        vm.prank(owner);
        poetry.approvePoem(1);
        assert(poetry.getPoemById(1).approved);
    }

    function testApprovePoemRestricted() public {
        assertFalse(poetry.getPoemById(0).approved);
        vm.prank(rando);
        vm.expectRevert();
        poetry.approvePoem(1);
        assertFalse(poetry.getPoemById(0).approved);
    }

    // New Poem

    function testCreatePoem() public {
        vm.prank(rando);
        uint256 id = poetry.createPoem("This is a poem.", .5 ether);
        assertEq(poetry.getPoemById(id).poemText, "This is a poem.");
        assertEq(poetry.ownerOf(id), rando);
    }

    // Getter Functions

    function testGetPoemById() public {
        assertEq(poetry.getPoemById(0).poemText, "Test poem");
    }

    function testGetLatestPoem() public {
        assertEq(poetry.getLatestPoem().poemText, "Test poem");
        vm.prank(rando);
        poetry.createPoem("New poem", .5 ether);
        assertEq(poetry.getLatestPoem().poemText, "New poem");
    }

    function testGetAllPoems() public {
        vm.startPrank(rando);
        for (uint8 i = 0; i < 10; i++) {
            poetry.createPoem("New poem", .5 ether);
        }
        vm.stopPrank();
        console.log(poetry.getAllPoems());
    }

    // Pricing

    function testSetPrice() public {
        vm.prank(rando);
        uint256 id = poetry.createPoem("This is a poem", .5 ether);
        vm.prank(rando);
        poetry.setPrice(id, .2 ether);
        assertEq(poetry.getPoemById(id).price, .2 ether);
    }

    function testFailNonOwnerSetsPrice() public {
        vm.prank(rando);
        uint256 id = poetry.createPoem("This is a poem", .5 ether);
        vm.prank(buyer);
        poetry.setPrice(id, .2 ether);
    }

    // Access Controls

    // Transfers

    function testExecuteSale() public {
        vm.prank(rando);
        uint256 price = .5 ether;
        uint256 id = poetry.createPoem("This is a poem.", price);
        vm.prank(owner);
        poetry.approvePoem(id);
        vm.prank(buyer);
        poetry.executeSale{value: price}(id);
        assertEq(poetry.ownerOf(id), buyer);
        assertEq(buyer.balance, 10 ether - price);
        assertEq(rando.balance, 10 ether + price - poetry.getListingFee());
        assertEq(owner.balance, 10 ether + poetry.getListingFee());
    }

    function testFailInsufficientFundsForSale() public {
        vm.prank(rando);
        uint256 price = .5 ether;
        uint256 id = poetry.createPoem("This is a poem.", price);
        vm.prank(owner);
        poetry.approvePoem(id);
        vm.prank(buyer);
        poetry.executeSale{value: price - 1}(id);
    }

    function testFailSellUnapprovedPoem() public {
        vm.prank(rando);
        uint256 price = .5 ether;
        uint256 id = poetry.createPoem("This is a poem.", price);
        vm.prank(buyer);
        poetry.executeSale{value: price}(id);
    }

    function testFailPoemNotForSale() public {
        vm.prank(rando);
        uint256 price = .5 ether;
        uint256 id = poetry.createPoem("This is a poem.", 0);
        vm.prank(owner);
        poetry.approvePoem(id);
        vm.prank(buyer);
        poetry.executeSale{value: 0 ether}(id);
    }
}
