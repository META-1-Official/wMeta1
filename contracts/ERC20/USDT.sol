// SPDX-License-Identifier: LicenseRef-LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    uint constant TOTAL_SUPPLY = 1e8; // 100M
    constructor() ERC20('USDT', 'USD Token') {
        _mint(msg.sender, TOTAL_SUPPLY * (10 ** decimals()));
    }
}
