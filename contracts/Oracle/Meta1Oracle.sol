//SPDX-License-Identifier: LicenseRef-LICENSE
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

import "./OracleStorage.sol";

// Complete oracle
// add roles and permissions in oracle, probably make a centralised contract for roles and permissions to be used in all
contract Meta1Oracle is ChainlinkClient, Ownable2Step {
    using Chainlink for Chainlink.Request;

    uint8 public constant ratePrecision = 8;
    uint32 public constant maxUpdateDelay = 86400; // price cannot be older then 1 d

    OracleStorage.CurrentRate public wMETAPrice;

    bytes32 immutable private jobId = "63d075483978407abcb810084853f2ed"; // for Kovan and local // e5b99e0a-2f79-4029-98187-b11f37c56a6
    uint256 immutable private payment = 1e17; // for Kovan and local

    constructor(
        address _link,
        address _oracle
    ) Ownable(msg.sender) {
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

        req.add('get', 'https://meta1.bucle.dev/ticker/USDT/META1');
        req.add('path', 'data,latest');
        req.addInt('times', int256(10**ratePrecision));

//        req.add('urlUpdatedAt', 'https://meta1.bucle.dev/ticker/USDT/META1');
//        req.add('path', 'updated_at');

        sendChainlinkRequest(req, payment);
    }

    function getLatestPrice() public view returns (uint128) {
        require(block.timestamp - wMETAPrice.updatedAt < maxUpdateDelay, "Price is too old");
        return wMETAPrice.price;
    }

    /* ========== CONSUMER FULFILL FUNCTIONS ========== */

    function fulfillPriceUpdate(bytes32 _requestId, uint256 _price)
        public
        recordChainlinkFulfillment(_requestId)
    {
        wMETAPrice.price = uint128(_price);
        wMETAPrice.updatedAt = uint32(block.timestamp);
    }

    /* ========== OTHER FUNCTIONS ========== */

    function getOracleAddress() external view returns (address) {
        return chainlinkOracleAddress();
    }

    function setOracle(address _oracle) external payable onlyOwner {
        setChainlinkOracle(_oracle);
    }

    function withdrawLink() public payable onlyOwner {
        LinkTokenInterface linkToken = LinkTokenInterface(
            chainlinkTokenAddress()
        );
        require(
            linkToken.transfer(msg.sender, linkToken.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}
