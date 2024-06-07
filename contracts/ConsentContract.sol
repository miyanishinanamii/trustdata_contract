// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MasterConsentContract.sol";

contract ConsentContract is ERC721, Ownable {
    struct Consent {
        address masterConsentContractAddress;
        uint256 masterConsentContractTokenId;
    }

    mapping(uint256 => Consent) public consents;
    uint256 public nextConsentId;

    event ConsentUpdated(uint256 indexed consentId, address masterConsentContractAddress, uint256 masterConsentContractTokenId);

    constructor(address initialOwner) Ownable(initialOwner) ERC721("ConsentContract", "CCNFT") {}

    function mintConsent(
        address to,
        address masterConsentContractAddress,
        uint256 masterConsentContractTokenId
    ) public onlyOwner {
        uint256 consentId = nextConsentId;
        _mint(to, consentId);
        consents[consentId] = Consent(masterConsentContractAddress, masterConsentContractTokenId);
        nextConsentId++;
    }

    function getConsentDetails(uint256 consentId) public view returns (Consent memory) {
        address owner = ownerOf(consentId);
        require(owner != address(0), "ConsentContract: consent does not exist");
        return consents[consentId];
    }

    function burnConsent(uint256 consentId) public onlyOwner {
        address owner = ownerOf(consentId);
        require(owner != address(0), "ConsentContract: consent does not exist");
        _burn(consentId);
        delete consents[consentId];
    }

    function updateConsent(
        uint256 consentId,
        address newMasterConsentContractAddress,
        uint256 newMasterConsentContractTokenId
    ) public onlyOwner {
        address owner = ownerOf(consentId);
        require(owner != address(0), "ConsentContract: consent does not exist");
        consents[consentId] = Consent(newMasterConsentContractAddress, newMasterConsentContractTokenId);
        emit ConsentUpdated(consentId, newMasterConsentContractAddress, newMasterConsentContractTokenId);
    }
}
