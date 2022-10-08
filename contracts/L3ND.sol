// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/iL3ndRegistry.sol";
import "./interfaces/iLoanFactory.sol";
import "./interfaces/iSuperToken.sol";

contract LendToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    constant address MATICX_ADDR = "0x3aD736904E9e65189c3000c7DD2c8AC8bB7cD4e3"

    address public REG_ADDRESS;
    uint256 public totalReceived;
    uint256 public totalValue;
    bool givingLoans;

    function initialize(address registryAddress) initializer public {
        __ERC20_init("Lend Token", "L3ND");
        __Ownable_init();
        __UUPSUpgradeable_init();

        REG_ADDRESS = registryAddress;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    event Received(
        address from, 
        uint amountReceived, 
        uint totalReceived, 
        uint totalValue
    );

    // When users send native token to this contract
    // we'll return tokens
    receive() external payable {
        totalReceived = totalReceived.add(msg.value);
        totalValue = totalValue.add(msg.value);
        emit Received(msg.sender, msg.value, totalReceived, totalValue);
    }

    function setGiving(bool status) public onlyOwner {
        givingLoans = status;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721Upgradeable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // A loan will be requested when sending the nft to the L3nd Vault
    function _afterTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override
    {

        uint loan_amount = 50;      // Native Tokens
        uint loan_blocks = 1234286; // Around 30 days if blocks are 2.1secs avg

        // Check we have enough to lend
        require(address(this).balance >= loan_amount, 'NO_FUNDS_TO_L3ND');

        // Check NFT Token is in white list
        require(iL3ndRegistry(REG_ADDRESS).isWhitelisted(tokenAddress) == true, 'NOT_WHITELISTED');

        // Check with L3ND Registry for no open loans
        require(iL3ndRegistry(REG_ADDRESS).getOpenLoan(debtor=msg.sender) == address(0), 'HAS_OPEN_LOAN');

        // Check with opengraph for NFT qualities
        // to calculate the risk and interest rate
        // TODO: LEVI


        // Ask loan factory to deploy Loan Contract
        address loanAddr = iLoanFactory.deployLoan(loan_amount, blocks);

        // Register open loan in registry
        iL3ndRegistry(REG_ADDRESS).setLoanActive(debtor=msg.sender, loanAddr=loanAddr);

        // Give Loan (Send native tokens)
        // (bool success, ) = payable(msg.sender).call{value:loan_amount}("");

        // Give Loan (Send maticx tokens (SuperFluid Matic Token))
        bool success = ISuperToken(MATICX_ADDR).transferFrom(address(this), msg.sender, loan_amount)

        require(success, "LOAN_FAILED");

        super._afterTokenTransfer(from, to, tokenId);
    }
}