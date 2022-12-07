// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import "./Test.t.sol";

/**
 * @dev Deployment Tests.
 */
contract Deployment is ElasticReceiptTokenTest {

    function testInvariants() public {
        assertEq(ert.totalSupply(), 0);
        assertEq(ert.scaledBalanceOf(address(0)), TOTAL_BITS);
        assertEq(ert.scaledTotalSupply(), 0);
    }

    function testContructor() public {
        // Constructor arguments.
        assertEq(ert.underlier(), address(underlier));
        assertEq(ert.name(), NAME);
        assertEq(ert.symbol(), SYMBOL);
        assertEq(ert.decimals(), uint8(DECIMALS));
    }

}
