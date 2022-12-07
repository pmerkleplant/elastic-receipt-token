// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";

contract ERC20Mock is ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals)
        ERC20(_name, _symbol, _decimals)
    {
        // NO-OP
    }

    function mint(address to, uint value) public virtual {
        _mint(to, value);
    }

    function burn(address from, uint value) public virtual {
        _burn(from, value);
    }
}
