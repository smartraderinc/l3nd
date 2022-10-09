// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface iLoanFactory{
    
    // Returns the address of the 
    // deployed loan contract
    function deployLoan(
        uint _lent, int96 _irate, address nftaddr, uint tokenId, address _debtor
    ) external payable returns (address);

}