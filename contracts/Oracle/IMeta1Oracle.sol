//SPDX-License-Identifier: LicenseRef-LICENSE
pragma solidity ^0.8.20;

interface IMeta1Oracle {
    function ratePrecision() external view returns(uint8);
    function getLatestPrice() external view returns (uint128);
}
