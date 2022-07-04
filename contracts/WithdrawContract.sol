// SPDX-License-Identifier: LicenseRef-LICENSE

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Oracle/IMeta1Oracle.sol";

contract WithdrawContract is OwnableUpgradeable {
    using SafeERC20 for IERC20Metadata;

    IERC20Metadata constant USDT = IERC20Metadata(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);

    IERC20Metadata wMeta1;
    IMeta1Oracle meta1Oracle;

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _wMeta1, address _meta1Oracle) public initializer {
        __Ownable_init();

        wMeta1 = IERC20Metadata(_wMeta1);
        meta1Oracle = IMeta1Oracle(_meta1Oracle);
    }

    function deposit(uint256 _amount) public {
        USDT.safeTransferFrom(msg.sender, address(this), _amount);
        // Normalise oracle price as per USDT token decimals
        uint256 meta1Price = (uint256(meta1Oracle.getLatestPrice()) * (10 ** USDT.decimals())) / 10 ** meta1Oracle.ratePrecision();
        // Multiplying with 1e8 to support values lower then the price of meta1 token upto 8 decimal precision
        uint256 depositAmount = ((_amount * 1e8) / meta1Price) * (10 ** (wMeta1.decimals() - 8));
        wMeta1.safeTransfer(msg.sender, depositAmount);
    }

    function withdraw(uint256 _amount) public {
        wMeta1.safeTransferFrom(msg.sender, address(this), _amount);
        // Normalise oracle price as per provided token decimals
        uint256 meta1Price = (uint256(meta1Oracle.getLatestPrice()) * (10 ** USDT.decimals())) / 10 ** meta1Oracle.ratePrecision();

        uint256 withdrawAmount = (_amount * meta1Price) / (10 ** (wMeta1.decimals()));
        USDT.safeTransfer(msg.sender, withdrawAmount);
    }

    function transferBNB(address _recipient, uint _amount) external onlyOwner {
        (bool success, ) = payable(_recipient).call{value:_amount}("");
        require(success, "WC: Transfer failed");
    }

    function _transferAnyToken(address _tokenAddress, address _recipient, uint _amount) external onlyOwner {
        require(IERC20(_tokenAddress).transfer(_recipient, _amount), "WC: Token transfer failed");
    }
}
