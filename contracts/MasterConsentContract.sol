// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MasterConsentContractNFT is ERC721, Ownable {
    struct MasterConsentContract {
        string metadataURI;
    }

    mapping(uint256 => MasterConsentContract) public masterConsentContracts;
    uint256 public nextMasterConsentContractId;

    constructor(address initialOwner) Ownable(initialOwner) ERC721("MasterConsentContractNFT", "MCCNFT") {}

    function mintMasterConsentContract(address to, string memory metadataURI) public onlyOwner {
        uint256 masterConsentContractId = nextMasterConsentContractId;
        _mint(to, masterConsentContractId);
        masterConsentContracts[masterConsentContractId] = MasterConsentContract(metadataURI);
        nextMasterConsentContractId++;
    }

    function getMasterConsentContractDetails(uint256 masterConsentContractId) public view returns (MasterConsentContract memory) {
        address owner = ownerOf(masterConsentContractId);
        require(owner != address(0), "MasterConsentContractNFT: master consent contract does not exist");
        return masterConsentContracts[masterConsentContractId];
    }

    function getLatestMasterConsentContractDetails() public view returns (MasterConsentContract memory) {
        uint256 latestId = nextMasterConsentContractId - 1;
        address owner = ownerOf(latestId);
        require(owner != address(0), "MasterConsentContractNFT: no master consent contracts exist");
        return masterConsentContracts[latestId];
    }
}

