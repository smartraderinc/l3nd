// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract L3ndRegistry is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    address L3ND_ADDR;
    using SafeMath for uint256;

    function initialize(address lend_addr) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
        L3ND_ADDR = lend_addr;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    struct NFTCredit {
        address tokenAddress;   // Token Address (is key in map)
        uint floorPrice;
        uint ltvRate;           // The percentage of the floor price that we'll lend
        uint interestRate;      // The interest rate x second
        uint index;  // Index in lut
    }

    mapping(address => NFTCredit) public whiteListMap;
    address[] public whiteListLUT; // Whitelisted NFT Look Up Table
    mapping(address => address) public openLoansMap; // Maps requester address to open loan contract

    function isWhitelisted(address tokenAddress) public view returns (bool) {
        return whiteListMap[tokenAddress].tokenAddress == tokenAddress;
    }

    function getOpenLoan(address debtor) public view returns (address) {
        return openLoansMap[debtor];
    }

    function getWhiteListCount() public view returns (uint256 count){
        return whiteListLUT.length;
    }

    event NFTAdded(address tokenAddress, uint floorPrice, uint ltvRate, uint interestRate);
    event NFTRemoved(address);

    function addToWhitelist(address tokenAddress, uint floorPrice, uint ltvRate, uint interestRate) public onlyOwner{
        require(whiteListMap[tokenAddress].tokenAddress == address(0), 'Already in whitelist');
        whiteListMap[tokenAddress].tokenAddress = tokenAddress;
        whiteListMap[tokenAddress].floorPrice = floorPrice;
        whiteListMap[tokenAddress].ltvRate = ltvRate;
        whiteListMap[tokenAddress].interestRate = interestRate;
        whiteListMap[tokenAddress].index = whiteListLUT.length;

        whiteListLUT.push(tokenAddress);

        emit NFTAdded(tokenAddress, floorPrice, ltvRate, interestRate);
    }

    function removeFromWhitelist(address tokenAddress) public onlyOwner{
        require(whiteListMap[tokenAddress].tokenAddress == tokenAddress, 'NOT_IN_WHITELIST');
        delete whiteListMap[tokenAddress];
        emit NFTRemoved(tokenAddress);
    }

    struct NFTBalance {
        address tokenAddress;   // Token Address (is key in map)
        uint[] tokenIds;
    }

    function getAmountToLend(address tokenAddress) public view returns(uint tokens) {
        require(whiteListMap[tokenAddress].tokenAddress != address(0), 'NOT_IN_WHITELIST');
        return whiteListMap[tokenAddress].floorPrice.div(100).mul(whiteListMap[tokenAddress].ltvRate);
    }


    // Get balances of whitelisted nfts from provided address
    // function getWhitelistedBalances(address addr) public view returns (NFTBalance[]){
    //     NFTBalance[] resp;
    //     for (uint i=0; i<whiteListLUT.length; i++) {
    //         whiteListMap[whiteListLUT[i]];

    //         // Check with nft balance
    //         balance = IERC721Upgradeable(token_address).balanceOf(addr);

    //         // if balance check
    //         // TODO: LEVI check with the graph? 
    //     }
    // }

    // First time called the status should be false
    // Setting it to false means an active loan has been paid
    function setLoanActive(address debtor, address loanAddr) public {
        // Validate only L3ND Contract can create new loan contracts
        require(msg.sender == L3ND_ADDR, 'UNAUTHORIZED');

        // Validate no open loans
        require(openLoansMap[debtor] == address(0), 'HAS_OPEN_LOAN');
        
        // Set open loan
        openLoansMap[debtor] = loanAddr;
    }

    // Set loan as payed
    // activating the loan in the map
    function setLoanInactive(address debtor) public {
        // Get loan contract address
        address actualLoanAddr = openLoansMap[debtor];

        // Validate is loan contract calling
        require(msg.sender == actualLoanAddr);

        // Remove open loan
        delete openLoansMap[debtor];
    }
}