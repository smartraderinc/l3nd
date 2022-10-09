// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./interfaces/iL3ndRegistry.sol";
import "./interfaces/iLoanFactory.sol";
import "./interfaces/iSuperToken.sol";
import "./interfaces/ISETH.sol";

contract ReceiverTest is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    IERC721ReceiverUpgradeable
{
    using SafeMath for uint256;
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    address internal constant MATICX_ADDR =
        0x3aD736904E9e65189c3000c7DD2c8AC8bB7cD4e3;

    address internal constant WETH_ADDR = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address internal constant ETHX_ADDR = 0x27e1e4E6BC79D93032abef01025811B7E4727e85;


    address public REG_ADDRESS;
    address public FACTORY_ADDRESS;

    uint256 public totalReceived;
    uint256 public totalValue;
    bool public givingLoans;
    uint256 public loanSize; // Native Tokens Lended
    uint256 constant loan_blocks = 1234286; // Around 30 days if blocks are 2.1secs avg
    int96 public flowRate;

    function initialize() public initializer {
        __ERC20_init("Lend Token", "L3ND");
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    // Event when received native tokens
    // for lending pool
    event Received(
        address from,
        uint256 amountReceived,
        address tokenAddress,
        uint256 totalReceived,
        uint256 totalValue
    );

    // Event emittedn when an NFT is received as collateral
    event ReceivedNFT(address from, address nft, uint256 tokenId);

    // When users send native token to this contract
    // we'll return tokens
    // receive() external payable {
    //     totalReceived = totalReceived.add(msg.value);
    //     totalValue = totalValue.add(msg.value);

    //     // Upgrade (Wrap into SuperToken)
    //     // the tokens we receive
    //     ISETH iseth = ISETH(MATICX_ADDR);
    //     iseth.upgradeByETH{value: msg.value}();

    //     emit Received(msg.sender, msg.value, totalReceived, totalValue);

    //     // Mint L3nd tokens on a 1 to 1 base
    //     _mint(msg.sender, msg.value);
    // }

    function setGiving(bool status) public onlyOwner {
        givingLoans = status;
    }

    function setLoanSize(uint256 _ls) public onlyOwner {
        loanSize = _ls;
    }

    function setFlowRate(int96 _fr) public onlyOwner {
        flowRate = _fr;
    }

    function setConfig(address _factory, address registryAddress) public onlyOwner {
        FACTORY_ADDRESS = _factory;
        REG_ADDRESS = registryAddress;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC20Upgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }


    // After receiving erc20 tokens (wETH)
    // We upgrade them to supertokens
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        address tokenAddress = msg.sender;

        emit Received(from, amount, tokenAddress, totalReceived, totalValue);

        super._afterTokenTransfer(from, to, amount);
    }


    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public virtual override returns (bytes4) {
        // msg.sender is the address of the NFT
        address tokenAddress = msg.sender;

        emit ReceivedNFT(from, tokenAddress, tokenId);

        return this.onERC721Received.selector;
    }
}
