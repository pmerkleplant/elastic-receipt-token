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

    //--------------------------------------------------------------------------
    // Upgradeable Specific Tests

    function testInitialization() public {
        assertEq(ertUpgradeable.underlier(), address(underlier));
        assertEq(ertUpgradeable.name(), NAME);
        assertEq(ertUpgradeable.symbol(), SYMBOL);
        assertEq(ertUpgradeable.decimals(), uint8(DECIMALS));
    }

    function testInitilizationFailsIfMintAlreadyExecuted(
        address user,
        uint amount
    ) public {
        vm.assume(user != address(0));
        vm.assume(amount != 0 && amount <= MAX_SUPPLY);

        underlier.mint(user, amount);

        vm.startPrank(user);
        {
            underlier.approve(address(ertUpgradeable), amount);
            ertUpgradeable.mint(amount);
        }
        vm.stopPrank();

        vm.expectRevert();
        ertUpgradeable.init(address(underlier), NAME, SYMBOL, uint8(DECIMALS));
    }
}
