// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ConsentContract.sol";
import "./TradeConsentContract.sol";

contract DataOwnershipNFT is ERC721URIStorage, Ownable {
    struct DataOwnership {
        address consentContractAddress;
        uint256 consentTokenId;
        address tradeConsentContractAddress;
        uint256 tradeConsentTokenId;
        uint256 approvalDate; // 承認日
    }

    mapping(uint256 => DataOwnership) public dataOwnerships;
    uint256 public nextDataOwnershipId;

    constructor(address initialOwner) Ownable(initialOwner) ERC721("DataOwnershipNFT", "DONFT") {}

    function mintDataOwnership(
        address to,
        string memory tokenURI,
        address consentContractAddress,
        uint256 consentTokenId,
        address tradeConsentContractAddress,
        uint256 tradeConsentTokenId
    ) public onlyOwner {
        uint256 dataOwnershipId = nextDataOwnershipId;
        _mint(to, dataOwnershipId);
        _setTokenURI(dataOwnershipId, tokenURI);
        dataOwnerships[dataOwnershipId] = DataOwnership(
            consentContractAddress,
            consentTokenId,
            tradeConsentContractAddress,
            tradeConsentTokenId,
            0 // 承認日は最初は設定しない
        );
        nextDataOwnershipId++;
    }

    function setApprovalDate(uint256 dataOwnershipId, uint256 approvalDate) public onlyOwner {
        require(ownerOf(dataOwnershipId) != address(0), "DataOwnershipNFT: data ownership does not exist");
        dataOwnerships[dataOwnershipId].approvalDate = approvalDate;
    }

    function setTokenURI(uint256 dataOwnershipId, string memory tokenURI) public onlyOwner {
        require(ownerOf(dataOwnershipId) != address(0), "DataOwnershipNFT: data ownership does not exist");
        _setTokenURI(dataOwnershipId, tokenURI);
    }

    function getDataOwnershipDetails(uint256 dataOwnershipId) public view returns (DataOwnership memory) {
        require(ownerOf(dataOwnershipId) != address(0), "DataOwnershipNFT: data ownership does not exist");
        return dataOwnerships[dataOwnershipId];
    }

    function burnDataOwnership(uint256 dataOwnershipId) public onlyOwner {
        require(ownerOf(dataOwnershipId) != address(0), "DataOwnershipNFT: data ownership does not exist");
        _burn(dataOwnershipId);
        delete dataOwnerships[dataOwnershipId];
    }

    function verifyOwnershipTradeConditions(
        uint256 dataOwnershipId,
        TradeConsentContract.TradeConditions memory conditions
    ) public view returns (bool) {
        require(ownerOf(dataOwnershipId) != address(0), "DataOwnershipNFT: data ownership does not exist");

        DataOwnership storage ownership = dataOwnerships[dataOwnershipId];
        TradeConsentContract tradeConsentContract = TradeConsentContract(ownership.tradeConsentContractAddress);

        return tradeConsentContract.verifyTradeConditions(ownership.tradeConsentTokenId, conditions);
    }

    function updateConsentDetails(uint256 dataOwnershipId, address consentContractAddress, uint256 consentTokenId) public onlyOwner {
        require(ownerOf(dataOwnershipId) != address(0), "DataOwnershipNFT: data ownership does not exist");
        dataOwnerships[dataOwnershipId].consentContractAddress = consentContractAddress;
        dataOwnerships[dataOwnershipId].consentTokenId = consentTokenId;
    }

    function updateTradeConsentDetails(uint256 dataOwnershipId, address tradeConsentContractAddress, uint256 tradeConsentTokenId) public onlyOwner {
        require(ownerOf(dataOwnershipId) != address(0), "DataOwnershipNFT: data ownership does not exist");
        dataOwnerships[dataOwnershipId].tradeConsentContractAddress = tradeConsentContractAddress;
        dataOwnerships[dataOwnershipId].tradeConsentTokenId = tradeConsentTokenId;
    }
}
