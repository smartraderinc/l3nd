// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

import "./NFTLoan.sol";

contract LoanFactory is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    address public L3ND_ADDR;
    address public L3ND_REG;

    CountersUpgradeable.Counter private _cpNonce;

    function initialize(address l3nd_addr, address l3nd_reg)
        public
        initializer
    {
        __Ownable_init();
        __UUPSUpgradeable_init();

        L3ND_ADDR = l3nd_addr;
        L3ND_REG = l3nd_reg;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function bytesToBytes32(bytes memory b, uint256 offset)
        private
        pure
        returns (bytes32)
    {
        bytes32 out;

        for (uint256 i = 0; i < 32; i++) {
            out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    // Returns the address of the newly deployed contract
    function deployLoan(
        uint256 _lent,
        int96 _irate,
        address _nftaddr,
        uint256 _tokenId,
        address _debtor
    ) public payable returns (address) {

        // This syntax is a newer way to invoke create2 without assembly, you just need to pass salt
        // https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2

        bytes32 _salted_bytes = bytesToBytes32(
            abi.encodePacked(_cpNonce.current()),
            0
        );
        _cpNonce.increment();
        address loan_addr = address(
            new NFTLoan{salt: _salted_bytes}(
                L3ND_ADDR,
                L3ND_REG,
                _lent,
                _irate,
                _nftaddr,
                _tokenId,
                _debtor
            )
        );

        return loan_addr;
    }
}
