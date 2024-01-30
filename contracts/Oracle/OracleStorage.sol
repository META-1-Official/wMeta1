//SPDX-License-Identifier: LicenseRef-LICENSE
pragma solidity ^0.8.20;

library OracleStorage {
    struct CurrentRate {
        uint128 price; // this must be always in dollars with exactly 8 decimal points
        uint updatedAt;
    }
}
