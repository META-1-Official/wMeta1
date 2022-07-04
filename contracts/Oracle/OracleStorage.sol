//SPDX-License-Identifier: LicenseRef-LICENSE
pragma solidity ^0.8.0;

library OracleStorage {
    struct CurrentRate {
        uint128 price; // this must be always in dollars with exactly 8 decimal points
        uint32 updatedAt;
    }
}
