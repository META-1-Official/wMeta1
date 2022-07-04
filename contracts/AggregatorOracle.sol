// SPDX-License-Identifier: LicenseRef-LICENSE

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AggregatorOracle {
    AggregatorV3Interface internal priceFeed;

    constructor(address AggregatorAddress) {
                priceFeed = AggregatorV3Interface(AggregatorAddress);
    }

    function getLatestPrice(uint8 _decimals) public view returns (int256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        uint8 baseDecimals = priceFeed.decimals();
        int256 basePrice = scalePrice(price, baseDecimals, _decimals);
        return basePrice;
    }

    function scalePrice(int256 _price, uint8 _priceDecimals, uint8 _decimals)
    internal
    pure
    returns (int256)
    {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }
}
