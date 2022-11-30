// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/Poetry.sol";

contract PoetryTest is Test {
    Poetry public poetry;

    address internal owner = msg.sender;
    address internal constant rando = address(1);
    address internal constant buyer = address(2);

    function setUp() public {
        vm.label(owner, "Owner");
        vm.label(rando, "Rando");
        vm.label(buyer, "Buyer");
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

    // New Poem

    function testCreatePoem() public {
        vm.prank(rando);
        uint256 id = poetry.createPoem("This is a poem.", .5 ether);
        assertEq(poetry.getPoemById(id).poemText, "This is a poem.");
        assertEq(poetry.ownerOf(id), rando);
    }

    // Getter Functions

    function testGetPoemCount() public {
        assertEq(poetry.getPoemCount(), 1);
        vm.prank(rando);
        poetry.createPoem("This is a poem.", .5 ether);
        assertEq(poetry.getPoemCount(), 2);
    }

    function testGetPoemById() public {
        assertEq(poetry.getPoemById(1).poemText, "Test poem");
    }

    function testGetLatestPoem() public {
        assertEq(poetry.getLatestPoem().poemText, "Test poem");
        vm.prank(rando);
        poetry.createPoem("New poem", .5 ether);
        assertEq(poetry.getLatestPoem().poemText, "New poem");
    }

    // Access Controls

    function testApprovePoemRestricted() public {
        assertFalse(poetry.getPoemById(1).approved);
        vm.prank(rando);
        vm.expectRevert();
        poetry.approvePoem(1);
        assertFalse(poetry.getPoemById(1).approved);
    }

    // Transfers

    function testExecuteSale() public {
        vm.prank(rando);
        uint256 id = poetry.createPoem("This is a poem.", .5 ether);
        vm.prank(owner);
        poetry.approvePoem(id);
        vm.prank(buyer);
        vm.mockCall(
            address(poetry),
            abi.encodeWithSelector(poetry.executeSale.selector, id, .5 ether),
            abi.encode(false)
        );
        assertEq(poetry.ownerOf(id), buyer);
    }

    function testFailSellUnapprovedPoem() public {
        vm.prank(rando);
        uint256 id = poetry.createPoem("This is a poem.", .5 ether);
        vm.prank(buyer);
        poetry.executeSale(id);
    }
}
