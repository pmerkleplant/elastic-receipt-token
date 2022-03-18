// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "ds-test/test.sol";

import "../ElasticReceiptToken.sol";

import {HEVM} from "./utils/HEVM.sol";
import {ElasticReceiptTokenMock}
    from "./utils/mocks/ElasticReceiptTokenMock.sol";
import {ERC20Mock} from "./utils/mocks/ERC20Mock.sol";

/**
 * @dev Root contract for ElasticReceiptToken Test Contracts.
 *
 *      Provides the setUp function, access to common test utils and internal
 *      constants from the ElasticReceiptToken.
 */
abstract contract Test is DSTest {
    HEVM internal constant EVM = HEVM(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    // SuT
    ElasticReceiptTokenMock ert;

    // Mocks
    ERC20Mock underlier;

    // Constants
    string internal constant NAME = "elastic receipt Token";
    string internal constant SYMBOL = "ERT";
    uint internal constant DECIMALS = 9;

    // Constants copied from SuT.
    uint internal constant MAX_UINT = type(uint).max;
    uint internal constant MAX_SUPPLY = 1_000_000_000e18;
    uint internal constant TOTAL_BITS = MAX_UINT - (MAX_UINT % MAX_SUPPLY);
    uint internal constant BITS_PER_UNDERLYING = TOTAL_BITS / MAX_SUPPLY;

    function setUp() public {
        underlier = new ERC20Mock("Test ERC20", "TEST", uint8(18));

        ert = new ElasticReceiptTokenMock(
            address(underlier),
            NAME,
            SYMBOL,
            uint8(DECIMALS)
        );
    }

    function mintToUser(address user, uint erts) public {
        underlier.mint(user, erts);

        EVM.startPrank(user);
        {
            underlier.approve(address(ert), type(uint).max);
            ert.mint(erts);
        }
        EVM.stopPrank();
    }

    function overflows(uint a, uint b) public pure returns (bool) {
        unchecked {
            uint x = a + b;
            return x < a || x < b;
        }
    }

    function underflows(uint a, uint b) public pure returns (bool) {
        unchecked {
            uint x = a - b;
            return x > a;
        }
    }

}
