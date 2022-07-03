// SPDX-License-Identifier: LicenseRef-LICENSE

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./Oracle.sol";

contract WithdrawContract is OwnableUpgradeable {
    using SafeERC20 for IERC20;

    mapping(address => address) public supportedCurrencies;
    IERC20 wMeta1;
    IERC20 withdrawalToken;

    // @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _wMeta1, address _withdrawalToken) public initializer {
        __Ownable_init();

        wMeta1 = IERC20(_wMeta1);
        withdrawalToken = IERC20(_withdrawalToken);

        addSupportedCurrency(
            0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee,
            0x9331b55D9830EF609A2aBCfAc0FBCE050A52fdEa
        );
    }

    function addSupportedCurrency(
        address tokenAddress,
        address aggregatorAddress
    ) public onlyOwner {
        supportedCurrencies[tokenAddress] = aggregatorAddress;
    }

    function removeSupportedCurrency(address tokenAddress) public onlyOwner {
        supportedCurrencies[tokenAddress] = address(0);
    }

    function getPrice(address tokenAddress) public view returns (uint256) {
        require(
            supportedCurrencies[tokenAddress] != address(0),
            "WC: Currency Not Supported."
        );
        Oracle oracle = Oracle(supportedCurrencies[tokenAddress]);
        int256 price = oracle.getLatestPrice();
        return uint256(price);
    }

    function deposit(address _tokenAddress, uint256 _amount) public {
        IERC20(_tokenAddress).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 depositAmount = _amount * getPrice(_tokenAddress);
        wMeta1.safeTransfer(msg.sender, depositAmount);
    }

    function withdraw(uint256 _amount) public {
        wMeta1.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 withdrawAmount = _amount / getPrice(address(withdrawalToken));
        withdrawalToken.safeTransfer(msg.sender, withdrawAmount);
    }

    function transferBNB(address _recipient, uint _amount) external {
        (bool success, ) = payable(_recipient).call{value:_amount}("");
        require(success, "WC: Transfer failed");
    }

    function _transferAnyToken(address _tokenAddress, address _recipient, uint _amount) external {
        require(IERC20(_tokenAddress).transfer(_recipient, _amount), "WC: Token transfer failed");
    }
}
