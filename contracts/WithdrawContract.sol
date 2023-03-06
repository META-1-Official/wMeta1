// SPDX-License-Identifier: LicenseRef-LICENSE

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./Oracle/IMeta1Oracle.sol";
import "./Oracle/OracleStorage.sol";

contract WithdrawContract is OwnableUpgradeable, AccessControlUpgradeable {
    using SafeERC20Upgradeable for IERC20MetadataUpgradeable;

    IERC20MetadataUpgradeable constant USDT = IERC20MetadataUpgradeable(0x89838Ad31A068883E49Da8950b3151a1a275adf0);
    bytes32 public constant PRICE_UPDATE_ROLE = keccak256("PRICE_UPDATE_ROLE");

    IERC20MetadataUpgradeable wMeta1;
    IMeta1Oracle meta1Oracle;
    OracleStorage.CurrentRate public wMETAPrice;

//    // @custom:oz-upgrades-unsafe-allow constructor
//    constructor() {
//        _disableInitializers();
//    }

    function initialize(address _wMeta1, address _meta1Oracle) public initializer {
        __Ownable_init();

        wMeta1 = IERC20MetadataUpgradeable(_wMeta1);
        meta1Oracle = IMeta1Oracle(_meta1Oracle);
    }

    modifier onlyPriceRoleUSer() {
        require(hasRole(PRICE_UPDATE_ROLE, msg.sender), 'Only PRU');
        _;
    }

    function calcDepositAmount(uint256 _amount) public view returns (uint256) {
        // Normalise oracle price as per USDT token decimals
        uint256 meta1Price = (uint256(wMETAPrice.price) * (10 ** USDT.decimals())) / 10 ** meta1Oracle.ratePrecision();
        // Multiplying with 1e8 to support values lower then the price of meta1 token upto 8 decimal precision
        return ((_amount * 1e8) / meta1Price) * (10 ** (wMeta1.decimals() - 8));
    }

    function deposit(uint256 _amount) public {
        USDT.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 depositAmount = calcDepositAmount(_amount);
        wMeta1.safeTransfer(msg.sender, depositAmount);
    }

    function calcWithdrawAmount(uint256 _amount) public view returns (uint256) {
        // Normalise oracle price as per provided token decimals
        uint256 meta1Price = (uint256(wMETAPrice.price) * (10 ** USDT.decimals())) / 10 ** meta1Oracle.ratePrecision();

        return (_amount * meta1Price) / (10 ** (wMeta1.decimals()));
    }

    function withdraw(uint256 _amount) public {
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
