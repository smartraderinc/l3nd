// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface iLoanFactory{
    
    // Returns the address of the 
    // deployed loan contract
    function deployLoan(
        uint lent, uint blocks
    ) external payable returns (address);

}