// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.10;

import "ds-test/test.sol";

import "./Test.t.sol";

/**
 * @dev ERC20 Tests.
 */
contract ERC20 is Test {

    bytes32 constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    function testApprove(address owner, address spender, uint amount)
        public
    {
        // Note that an approval of zero is valid.
        if (owner == address(0) || spender == address(0)) {
            return;
        }

        EVM.prank(owner);
        assertTrue(ert.approve(spender, amount));

        assertEq(ert.allowance(owner, spender), amount);
    }

    function testApproveInf(address owner, address spender) public {
        if (owner == address(0) || spender == address(0)) {
            return;
        }

        mintToUser(owner, 1e9);

        EVM.prank(owner);
        assertTrue(ert.approve(spender, type(uint).max));

        EVM.prank(spender);
        assertTrue(ert.transferFrom(owner, spender, 1e9));

        assertEq(ert.allowance(owner, spender), type(uint).max);
    }

    function testIncreaseAllowance(
        address owner,
        address spender,
        uint erts
    ) public {
        // Note that an allowance increase of zero is valid.
        if (owner == address(0) || spender == address(0)) {
            return;
        }

        EVM.prank(owner);
        assertTrue(ert.increaseAllowance(spender, erts));

        assertEq(ert.allowance(owner, spender), erts);
    }

    function testDecreaseAllowance(
        address owner,
        address spender,
        uint erts
    ) public {
        // Note that an allowance increase/decrease of zero is valid.
        if (owner == address(0) || spender == address(0)) {
            return;
        }

        EVM.prank(owner);
        assertTrue(ert.increaseAllowance(spender, erts));

        EVM.prank(owner);
        assertTrue(ert.decreaseAllowance(spender, erts));

        assertEq(ert.allowance(owner, spender), 0);
    }

    function testTransfer(address from, address to, uint erts)
        public
    {
        if (from == address(0) || to == address(0) || erts == 0) {
            return;
        }
        if (erts > MAX_SUPPLY) {
            return;
        }

        mintToUser(from, erts);

        EVM.prank(from);
        assertTrue(ert.transfer(to, erts));

        if (from != to) {
            assertEq(ert.balanceOf(from), 0);
        }
        assertEq(ert.balanceOf(to), erts);
    }

    function testTransferAll(address from, address to, uint erts)
        public
    {
        if (from == address(0) || to == address(0) || erts == 0) {
            return;
        }
        if (erts > MAX_SUPPLY) {
            return;
        }

        mintToUser(from, erts);

        EVM.prank(from);
        assertTrue(ert.transferAll(to));

        assertEq(ert.balanceOf(from), 0);
        assertEq(ert.balanceOf(to), erts);
    }

    function testTransferFrom(address owner, address spender, uint erts)
        public
    {
        if (owner == address(0) || spender == address(0) || erts == 0) {
            return;
        }
        if (erts > MAX_SUPPLY) {
            return;
        }

        mintToUser(owner, erts);

        EVM.prank(owner);
        assertTrue(ert.approve(spender, erts));

        EVM.prank(spender);
        assertTrue(ert.transferFrom(owner, spender, erts));

        assertEq(ert.balanceOf(owner), 0);
        assertEq(ert.balanceOf(spender), erts);
    }

    function testTransferAllFrom(
        address owner,
        address spender,
        uint erts
    ) public {
        if (owner == address(0) || spender == address(0) || erts == 0) {
            return;
        }
        if (erts > MAX_SUPPLY) {
            return;
        }

        mintToUser(owner, erts);

        EVM.prank(owner);
        assertTrue(ert.approve(spender, erts));

        EVM.prank(spender);
        assertTrue(ert.transferAllFrom(owner, spender));

        assertEq(ert.balanceOf(owner), 0);
        assertEq(ert.balanceOf(spender), erts);
    }

    function testTransferAllFromWithZeroToken(
        address owner,
        address spender
    ) public {
        if (owner == address(0) || spender == address(0) || owner == spender) {
            return;
        }

        // Create owner balance with bit amount unequal to zero but token
        // balance being zero.
        mintToUser(spender, 1e18);
        mintToUser(owner, 1);
        underlier.burn(address(ert), 1e18);
        ert.rebase();

        assertEq(ert.balanceOf(owner), 0);
        assertTrue(ert.scaledBalanceOf(owner) != 0);

        EVM.prank(spender);
        try ert.transferAllFrom(owner, spender) {
            revert();
        } catch {
            // Fails due to not having enough allowance.
        }

        EVM.prank(owner);
        ert.approve(spender, 1);

        EVM.prank(spender);
        assertTrue(ert.transferAllFrom(owner, spender));

        assertEq(ert.allowance(owner, spender), 0);
    }

    function testFailTransferInsufficientBalance(
        address from,
        address to,
        uint erts
    ) public {
        if (from == address(0) || to == address(0) || erts == 0) {
            revert();
        }
        if (erts > MAX_SUPPLY) {
            revert();
        }

        mintToUser(from, erts-1);

        // Fails with underflow due to insufficient balance.
        EVM.prank(from);
        ert.transfer(to, erts);
    }

    function testFailTransferFromInsufficientBalance(
        address owner,
        address spender,
        uint erts
    ) public {
        if (owner == address(0) || spender == address(0) || erts == 0) {
            revert();
        }
        if (erts > MAX_SUPPLY) {
            revert();
        }

        mintToUser(owner, erts-1);

        EVM.prank(owner);
        ert.approve(spender, erts);

        // Fails with underflow due to insufficient balance.
        EVM.prank(spender);
        ert.transferFrom(owner, owner, erts);
    }

    function testFailTransferFromInsufficientAllowance(
        address owner,
        address spender,
        uint erts
    ) public {
        if (owner == address(0) || spender == address(0) || erts == 0) {
            revert();
        }
        if (erts > MAX_SUPPLY) {
            revert();
        }

        mintToUser(owner, erts);

        EVM.prank(owner);
        ert.approve(spender, erts-1);

        // Fails with underflow due to insufficient allowance.
        EVM.prank(spender);
        ert.transferFrom(owner, owner, erts);
    }

    function testFailTransferAllFromInsufficientAllowance(
        address owner,
        address spender,
        uint erts
    ) public {
        if (owner == address(0) || spender == address(0) || erts == 0) {
            revert();
        }
        if (erts > MAX_SUPPLY) {
            revert();
        }

        mintToUser(owner, erts);

        EVM.prank(owner);
        ert.approve(spender, erts-1);

        // Fails with underflow due to insufficient allowance.
        EVM.prank(spender);
        ert.transferFrom(owner, owner, erts);
    }

    function testPermit() public {
        uint256 privateKey = 0xBEEF;
        address owner = EVM.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = EVM.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    ert.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        ert.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);

        assertEq(ert.allowance(owner, address(0xCAFE)), 1e18);
        assertEq(ert.nonces(owner), 1);
    }

    function testFailPermitBadNonce() public {
        uint256 privateKey = 0xBEEF;
        address owner = EVM.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = EVM.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    ert.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 1, block.timestamp))
                )
            )
        );

        // Fails due to nonce not being strictly increasing by 1.
        ert.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }

    function testFailPermitBadDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = EVM.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = EVM.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    ert.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        // Fails due to deadline being in the past.
        ert.permit(owner, address(0xCAFE), 1e18, block.timestamp + 1, v, r, s);
    }

    function testFailPermitPastDeadline() public {
        uint256 privateKey = 0xBEEF;
        address owner = EVM.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = EVM.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    ert.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp - 1))
                )
            )
        );

        // Fails due to deadline being in the past.
        ert.permit(owner, address(0xCAFE), 1e18, block.timestamp - 1, v, r, s);
    }

    function testFailPermitReplay() public {
        uint256 privateKey = 0xBEEF;
        address owner = EVM.addr(privateKey);

        (uint8 v, bytes32 r, bytes32 s) = EVM.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    ert.DOMAIN_SEPARATOR(),
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, address(0xCAFE), 1e18, 0, block.timestamp))
                )
            )
        );

        ert.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
        // Fails due to being a replay attack.
        ert.permit(owner, address(0xCAFE), 1e18, block.timestamp, v, r, s);
    }

}
