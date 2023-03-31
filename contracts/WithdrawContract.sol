// SPDX-License-Identifier: LicenseRef-LICENSE

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Oracle/OracleStorage.sol";

contract WithdrawContract is Ownable, AccessControl {
    using SafeERC20 for IERC20Metadata;

    uint8 public constant ratePrecision = 8;
    bytes32 public constant PRICE_UPDATE_ROLE = keccak256("PRICE_UPDATE_ROLE");

    IERC20Metadata USDT;
    IERC20Metadata wMeta1;
    OracleStorage.CurrentRate public wMETAPrice;

    constructor(address _wMeta1, address _usdt) {
        wMeta1 = IERC20MetadataUpgradeable(_wMeta1);
        USDT = IERC20MetadataUpgradeable(_usdt);
    }

    modifier onlyPriceRoleUSer() {
        require(hasRole(PRICE_UPDATE_ROLE, msg.sender), 'Only PRU');
        _;
    }

    function calcDepositAmount(uint256 _amount) public view returns (uint256) {
        // Normalise oracle price as per USDT token decimals
        uint256 meta1Price = (uint256(wMETAPrice.price) * (10 ** USDT.decimals())) / 10 ** ratePrecision;
        // Multiplying with 1e8 to support values lower then the price of meta1 token upto 8 decimal precision
        return ((_amount * 1e8) / meta1Price) * (10 ** (wMeta1.decimals() - 8));
    }

    function deposit(uint256 _amount) public {
        require(wMETAPrice.updatedAt > block.timestamp - 3600, "WC: price is more then 1 hour old");

        USDT.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 depositAmount = calcDepositAmount(_amount);
        wMeta1.safeTransfer(msg.sender, depositAmount);
    }

    function calcWithdrawAmount(uint256 _amount) public view returns (uint256) {
        // Normalise oracle price as per provided token decimals
        uint256 meta1Price = (uint256(wMETAPrice.price) * (10 ** USDT.decimals())) / 10 ** ratePrecision;

        return (_amount * meta1Price) / (10 ** (wMeta1.decimals()));
    }

    function withdraw(uint256 _amount) public {
        require(wMETAPrice.updatedAt > block.timestamp - 3600, "WC: price is more then 1 hour old");

        wMeta1.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 withdrawAmount = calcWithdrawAmount(_amount);
        USDT.safeTransfer(msg.sender, withdrawAmount);
    }

    function transferBNB(address _recipient, uint _amount) external onlyOwner {
        (bool success, ) = payable(_recipient).call{value:_amount}("");
        require(success, "WC: Transfer failed");
    }

    function _transferAnyToken(address _tokenAddress, address _recipient, uint _amount) external onlyOwner {
        require(IERC20MetadataUpgradeable(_tokenAddress).transfer(_recipient, _amount), "WC: Token transfer failed");
    }


    /**
    * @dev this function give the price update role to the user
       @param
       _user :- wallet address
    */
    function givePriceUpdateRole(address _user) external onlyOwner {
        _grantRole(PRICE_UPDATE_ROLE, _user);
    }

    /**
     * @dev this function update the price only by price update role to the user
       @param
       _price :- 1 meta token price in usdt 8 decimals
    */
    function updateMetaPrice(uint128 _price) external onlyPriceRoleUSer {
        wMETAPrice.price = _price;
        wMETAPrice.updatedAt = uint32(block.timestamp);
    }

}
