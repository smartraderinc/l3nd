// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "./interfaces/iL3ndRegistry.sol";
import "./interfaces/iSuperToken.sol";

contract NFTLoan is ReentrancyGuard {
    using SafeMath for uint256;

    address constant MATICX_ADDR = 0x3aD736904E9e65189c3000c7DD2c8AC8bB7cD4e3;

    address public debtor;
    address public nftaddr;
    uint256 public tokenId;
    uint256 public lent;
    uint256 public paid;
    uint256 public loanedInBlock; // Loan when the credit was granted
    uint256 public loanedInTS; // Timestamp when the credit was granted
    int96 interestRate; // Wei x second

    address public L3ND_ADDR; // The L3nd Token & Vault
    address public REG_ADDRESS; // The L3nd Registry Address

    event Received(address, uint256, uint256);
    event LoanPaid(address from, uint256 amountLent, uint256 amountPaid);

    constructor(
        address _l3nd_addr,
        address _l3nd_reg,
        uint256 _lent,
        int96 _irate,
        address _nftaddr,
        uint256 _tokenId,
        address _debtor
    ) {
        L3ND_ADDR = _l3nd_addr;
        REG_ADDRESS = _l3nd_reg;
        lent = _lent;
        loanedInBlock = block.number;
        loanedInTS = block.timestamp;
        nftaddr = _nftaddr;
        tokenId = _tokenId;
        interestRate = _irate;
        debtor = _debtor;
    }

    // Process debt payments
    // This payments reduces the capital lended value
    receive() external payable {
        paid = paid.add(msg.value);
        emit Received(msg.sender, lent, paid);

        // Send funds to L3ND Vault
        (bool success, ) = payable(L3ND_ADDR).call{
            value: msg.value
        }("");
        require(success, "Transfer failed.");

        if (ISuperToken(MATICX_ADDR).balanceOf(address(this)) > 0) {
            // Send interests paid in SuperTokens to L3ND vault
            success = ISuperToken(MATICX_ADDR).transferFrom(
                address(this),
                msg.sender,
                ISuperToken(MATICX_ADDR).balanceOf(address(this))
            );
        }

        // Check if it has been paid in full
        if (paid >= lent) {
            emit LoanPaid(msg.sender, lent, paid);

            // Mark as paid in registry
            iL3ndRegistry(REG_ADDRESS).setLoanInactive(debtor);
        }
    }

    function getNFTBack() public {
        // Check it has been paid
        require(paid >= lent, "NOT_PAID_YET");

        // Check is owner
        require(msg.sender == debtor, "NOT_YOURS");

        // Check due time
        // require(block.number <= dueInBlock, 'EXPIRED');

        // TODO:
        // Check all interests have been paid
        // Use deployed ts & flow rate

        // Transfer NFT back
        IERC721Upgradeable(nftaddr).safeTransferFrom(
            address(this),
            debtor,
            tokenId
        );
    }
}
