// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface iL3ndRegistry{
    function isWhitelisted(address tokenAddress) external returns (bool);

    function getOpenLoan(address debtorAddress) external returns (address loanAddress);
}