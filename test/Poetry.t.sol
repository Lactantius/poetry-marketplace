// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Poetry.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        poetry = new Poetry();
    }

    function testGetListingFee() public {
        assertEq(poetry.getListingFee(), 0.01 ether);
    }
}
