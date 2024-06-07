// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MasterTradeConsentContract.sol";

contract TradeConsentContract is ERC721, Ownable {
    enum Permission {
        ALLOW,
        DENY,
        ANONYMOUS_PROCESSING_ONLY
    }

    struct TradeConditions {
        bool allowAnalysis;
        bool allowViewing;
        Permission allowCopying;
        bool acceptAds;
        uint256 minAdPrice;
        uint256 minTradePrice;
        bool allowPublicResearchUse;
        bool confirmEachContract;
    }

    struct TradeConsent {
        address masterTradeContractAddress;
        uint256 masterTradeContractTokenId;
        TradeConditions tradeConditions;
    }

    mapping(uint256 => TradeConsent) public tradeConsents;
    uint256 public nextTradeConsentId;

    event TradeConsentUpdated(
        uint256 indexed tradeConsentId,
        address masterTradeContractAddress,
        uint256 masterTradeContractTokenId,
        TradeConditions tradeConditions
    );

    constructor(address initialOwner) Ownable(initialOwner) ERC721("TradeConsentContract", "TCCNFT") {}

    function mintTradeConsent(
        address to,
        address masterTradeContractAddress,
        uint256 masterTradeContractTokenId,
        bool allowAnalysis,
        bool allowViewing,
        Permission allowCopying,
        bool acceptAds,
        uint256 minAdPrice,
        uint256 minTradePrice,
        bool allowPublicResearchUse,
        bool confirmEachContract
    ) public onlyOwner {
        uint256 tradeConsentId = nextTradeConsentId;
        _mint(to, tradeConsentId);
        tradeConsents[tradeConsentId] = TradeConsent(
            masterTradeContractAddress,
            masterTradeContractTokenId,
            TradeConditions(
                allowAnalysis,
                allowViewing,
                allowCopying,
                acceptAds,
                minAdPrice,
                minTradePrice,
                allowPublicResearchUse,
                confirmEachContract
            )
        );
        nextTradeConsentId++;
    }

    function getTradeConsentDetails(uint256 tradeConsentId) public view returns (TradeConsent memory) {
        require(ownerOf(tradeConsentId) != address(0), "TradeConsentContract: trade consent does not exist");
        return tradeConsents[tradeConsentId];
    }

    function burnTradeConsent(uint256 tradeConsentId) public onlyOwner {
        require(ownerOf(tradeConsentId) != address(0), "TradeConsentContract: trade consent does not exist");
        _burn(tradeConsentId);
        delete tradeConsents[tradeConsentId];
    }

    function updateTradeConsent(
        uint256 tradeConsentId,
        address newMasterTradeContractAddress,
        uint256 newMasterTradeContractTokenId,
        TradeConditions memory newTradeConditions
    ) public onlyOwner {
        require(ownerOf(tradeConsentId) != address(0), "TradeConsentContract: trade consent does not exist");
        tradeConsents[tradeConsentId] = TradeConsent(newMasterTradeContractAddress, newMasterTradeContractTokenId, newTradeConditions);
        emit TradeConsentUpdated(tradeConsentId, newMasterTradeContractAddress, newMasterTradeContractTokenId, newTradeConditions);
    }

    function verifyTradeConditions(
        uint256 tradeConsentId,
        TradeConditions memory conditions
    ) public view returns (bool) {
        require(ownerOf(tradeConsentId) != address(0), "TradeConsentContract: trade consent does not exist");

        TradeConsent storage tradeConsent = tradeConsents[tradeConsentId];
        TradeConditions storage actualConditions = tradeConsent.tradeConditions;

        return (
            actualConditions.allowAnalysis == conditions.allowAnalysis &&
            actualConditions.allowViewing == conditions.allowViewing &&
            actualConditions.allowCopying == conditions.allowCopying &&
            actualConditions.acceptAds == conditions.acceptAds &&
            actualConditions.minAdPrice <= conditions.minAdPrice &&
            actualConditions.minTradePrice <= conditions.minTradePrice &&
            actualConditions.allowPublicResearchUse == conditions.allowPublicResearchUse &&
            actualConditions.confirmEachContract == conditions.confirmEachContract
        );
    }
}
