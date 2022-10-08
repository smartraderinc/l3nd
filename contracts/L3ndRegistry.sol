// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC721Upgradeable.sol";

contract L3ndRegistry is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    mapping(address => bool) public whiteListMap;
    address[] public whiteListLUT; // Whitelisted NFT Look Up Table
    mapping(address => address) public openLoansMap; // Maps requester address to open loan contract

    function isWhitelisted(address tokenAddress) public returns (bool) {
        return whiteListMap[tokenAddress];
    }

    function getOpenLoan(address debtorAddress) public returns (address) {
        return openLoansMap[debtorAddress];
    }

    event NFTAdded(address);
    event NFTRemoved(address);

    function addToWhitelist(address tokenAddress) public onlyOwner{
        require(whiteListMap[tokenAddress] == false, 'Already in whitelist');
        whiteListMap[tokenAddress] = true;
        emit NFTAdded(tokenAddress);
    }

    function removeFromWhitelist(address tokenAddress) public onlyOwner{
        require(whiteListMap[tokenAddress] == true, 'Not in whitelist');
        delete whiteListMap[tokenAddress];
        emit NFTRemoved(tokenAddress);
    }

    struct NFTBalance {
        address tokenAddress;   // Token Address (is key in map)
        uint[] tokenIds;
    }

    // Get balances of whitelisted nfts from provided address
    function getWhitelistedBalances(address addr) public view returns (NFTBalance[]){
        resp = [];
        for (uint i=0; i<whiteListLUT.length; i++) {
            getItem[whiteListLUT[i]];

            // Check with nft balance
            balance = IERC721Upgradeable(token_address).balanceOf(addr);

            // if balance check
            // TODO: LEVI check with the graph? 
        }
    }
}