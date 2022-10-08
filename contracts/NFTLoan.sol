// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "./interfaces/iL3ndRegistry.sol";

contract NFTLoan is ReentrancyGuard{

    using SafeMath for uint256;

    address public debtor;
    address public nftaddr;
    uint public tokenId;
    uint public lent;
    uint public paid;
    uint public loanedInBlock;  // Loan when the credit was granted
    uint public loanedInTS;     // Timestamp when the credit was granted
    
    address L3ND_ADDR; // The L3nd Token & Vault

    event Received(address, uint, uint);

    constructor(address _l3nd_addr, uint _lent, uint _irate, address nftaddr, uint tokenId) {
        L3ND_ADDR = _l3nd_addr;
        lent = _lent;
        loanedInBlock = block.number;
        loanedInTS = block.timestamp;
        nftaddr = _nftaddr;
        tokenId = _tokenId;
        interestRate = _irate;
    }

    // Process debt payments
    // This payments reduces the capital lended value
    receive() external payable {
        paid = paid.add(msg.value);
        emit Received(msg.sender, lent, paid);

        // Send funds to L3ND Vault
        (bool success, ) = payable(L3ND_ADDR).call{value:address(this).balance}("");
        require(success, "Transfer failed.");

        // Check if it has been paid in full
        if (paid >= lent) {
            emit LoanPaid(msg.sender, lent, paid);

            // Mark as paid in registry
            iL3ndRegistry(REG_ADDRESS).setLoanInactive(debtor);
        }
    }

    function getNFTBack () public {
        // Check it has been paid
        require(paid >= lent, 'NOT_PAID_YET');
        
        // Check is owner
        require(msg.sender == debtor, 'NOT_YOURS');

        // Check due time
        require(block.number <= dueInBlock, 'EXPIRED');


        // Transfer NFT back
        IERC721Upgradeable(nftaddr).safeTransferFrom(address(this), debtor, tokenId);

    }
}