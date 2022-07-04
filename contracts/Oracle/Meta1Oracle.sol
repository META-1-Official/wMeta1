//SPDX-License-Identifier: LicenseRef-LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./OracleStorage.sol";

// Complete oracle
// add roles and permissions in oracle, probably make a centralised contract for roles and permissions to be used in all
contract Meta1Oracle is ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;

    uint8 public constant ratePrecision = 4;
    uint32 public constant maxUpdateDelay = 86400; // price cannot be older then 1 d

    OracleStorage.CurrentRate public wMETAPrice;

    bytes32 constant private jobId = "ca98366cc7314957b8c012c72f05aeeb"; // for Kovan and local
    uint256 constant private payment = 1e17; // for Kovan and local

//    bytes32 constant private jobId = "94f9b202c7e04c988ce39674f825389d"; // for Mainnet
//    uint256 constant private payment = 1e18; // for Mainnet

    constructor(
        address _link,
        address _oracle
    ) {
        setChainlinkToken(_link);
        setChainlinkOracle(_oracle);
    }

    /* ========== CONSUMER REQUEST FUNCTIONS ========== */

    function requestPriceUpdate() public {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillPriceUpdate.selector
        );

        req.add('urlPrice', 'https://meta1.bucle.dev/ticker/USDT/META1');
        req.add('pathPrice', 'data,latest');
        req.addInt('times', int256(10**ratePrecision));
        req.add('urlUpdatedAt', 'https://meta1.bucle.dev/ticker/USDT/META1');
        req.add('path', 'updated_at');

        sendChainlinkRequest(req, payment);
    }

    function getLatestPrice() public view returns (uint128) {
        require(block.timestamp - wMETAPrice.updatedAt < maxUpdateDelay, "Price is too old");
        return wMETAPrice.price;
    }

    /* ========== CONSUMER FULFILL FUNCTIONS ========== */

    function fulfillPriceUpdate(bytes32 _requestId, uint256 _price, uint256 _updated_at)
        public
        recordChainlinkFulfillment(_requestId)
    {
        wMETAPrice.price = uint128(_price);
        wMETAPrice.updatedAt = uint32(_updated_at);
    }

    /* ========== OTHER FUNCTIONS ========== */

    function getOracleAddress() external view returns (address) {
        return chainlinkOracleAddress();
    }

    function setOracle(address _oracle) external onlyOwner {
        setChainlinkOracle(_oracle);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface linkToken = LinkTokenInterface(
            chainlinkTokenAddress()
        );
        require(
            linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
