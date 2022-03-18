// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "ds-test/test.sol";

import "./Test.t.sol";

/**
 * @dev Mint/Burn Tests.
 */
contract MintBurn is Test {

    function testFailMintMoreThanMAX_SUPPLY(address to) public {
        if (to == address(0)) {
            revert();
        }

        // Fails with MaxSupplyReached.
        mintToUser(to, MAX_SUPPLY + 1);
    }

    function testFailBurnAll(address to, uint erts) public {
        if (to == address(0) || erts == 0) {
            revert();
        }

        mintToUser(to, erts);

        // Fails with Division by 0.
        EVM.prank(to);
        ert.burn(erts);
    }

}
