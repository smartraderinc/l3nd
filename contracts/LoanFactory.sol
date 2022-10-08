// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./Loan.sol";

contract LoanFactory is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    address L3ND_ADDR;
    CountersUpgradeable.Counter private _cpNonce;

    function initialize(address l3nd_addr) initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();

        L3ND_ADDR = l3nd_addr;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function bytesToBytes32(bytes memory b, uint offset) private pure returns (bytes32) {
        bytes32 out;

        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    // Returns the address of the newly deployed contract
    function deployLoan(
        uint lent, uint blocks
    ) public payable onlyOwner returns (address) {

        // Only l3nd contract can call
        require(msg.sender == L3ND_ADDR, 'NOT_L3ND');

        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2

        bytes32 _salted_bytes = bytesToBytes32(abi.encodePacked(_cpNonce.current()), 0);
        _cpNonce.increment();
        address loan_addr = address(new NFTLoan{salt: _salted_bytes}(L3ND_ADDR, lent, blocks));

        NFTItemMap[og_addr].token_ids.push(tokenId);

        NFTLoan(loan_addr).setMyPass(mymasterpass);

        MasterPass(mymasterpass).mintForAll(loan_addr, _uri);
        
        return loan_addr;
    }

}