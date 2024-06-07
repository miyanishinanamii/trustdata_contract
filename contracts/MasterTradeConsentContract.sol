// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MasterTradeContractNFT is ERC721, Ownable {
    struct MasterTradeContract {
        string metadataURI;
    }

    mapping(uint256 => MasterTradeContract) public masterTradeContracts;
    uint256 public nextMasterTradeContractId;

    constructor(address initialOwner) Ownable(initialOwner) ERC721("MasterTradeContractNFT", "MTCNFT") {}

    function mintMasterTradeContract(address to, string memory metadataURI) public onlyOwner {
        uint256 masterTradeContractId = nextMasterTradeContractId;
        _mint(to, masterTradeContractId);
        masterTradeContracts[masterTradeContractId] = MasterTradeContract(metadataURI);
        nextMasterTradeContractId++;
    }

    function getMasterTradeContractDetails(uint256 masterTradeContractId) public view returns (MasterTradeContract memory) {
        address owner = ownerOf(masterTradeContractId);
        require(owner != address(0), "MasterTradeContractNFT: master trade contract does not exist");
        return masterTradeContracts[masterTradeContractId];
    }

    function getLatestMasterTradeContractDetails() public view returns (MasterTradeContract memory) {
        require(nextMasterTradeContractId > 0, "MasterTradeContractNFT: no master trade contracts exist");
        return masterTradeContracts[nextMasterTradeContractId - 1];
    }
}
