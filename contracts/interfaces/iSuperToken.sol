interface ISuperToken is ISuperfluidToken, TokenInfo, IERC20, IERC777 {

    function initialize(
        IERC20 underlyingToken,
        uint8 underlyingDecimals,
        string calldata n,
        string calldata s
    ) external;

    /**************************************************************************
    * TokenInfo & ERC777
    *************************************************************************/

    function name() external view override(IERC777, TokenInfo) returns (string memory);
    function symbol() external view override(IERC777, TokenInfo) returns (string memory);
    function decimals() external view override(TokenInfo) returns (uint8);
    
    /**************************************************************************
    * ERC20 & ERC777
    *************************************************************************/
    
    function totalSupply() external view override(IERC777, IERC20) returns (uint256);
    function balanceOf(address account) external view override(IERC777, IERC20) returns(uint256 balance);
    
    
    /**************************************************************************
    * ERC20
    *************************************************************************/
    
    function transfer(address recipient, uint256 amount) external override(IERC20) returns (bool);
    function allowance(address owner, address spender) external override(IERC20) view returns (uint256);
    function approve(address spender, uint256 amount) external override(IERC20) returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external override(IERC20) returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    /**************************************************************************
    * ERC777
    *************************************************************************/

    function granularity() external view override(IERC777) returns (uint256);
    function send(address recipient, uint256 amount, bytes calldata data) external override(IERC777);
    function burn(uint256 amount, bytes calldata data) external override(IERC777);
    function isOperatorFor(address operator, address tokenHolder) external override(IERC777) view returns (bool);
    function authorizeOperator(address operator) external override(IERC777);
    function revokeOperator(address operator) external override(IERC777);
    function defaultOperators() external override(IERC777) view returns (address[] memory);
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external override(IERC777);
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external override(IERC777);
    
    /**************************************************************************
     * SuperToken custom token functions
     *************************************************************************/
    
    function selfMint(
        address account,
        uint256 amount,
        bytes memory userData
    ) external;
   function selfBurn(
       address account,
       uint256 amount,
       bytes memory userData
   ) external;
   function selfTransferFrom(
        address sender,
        address spender,
        address recipient,
        uint256 amount
   ) external;
   function selfApproveFor(
        address account,
        address spender,
        uint256 amount
   ) external;
    
   /**************************************************************************
    * SuperToken extra functions
    *************************************************************************/

   function transferAll(address recipient) external;
   
   /**************************************************************************
   * ERC20 wrapping
   *************************************************************************/
   
   function getUnderlyingToken() external view returns(address tokenAddr);
   function upgrade(uint256 amount) external;
   function upgradeTo(address to, uint256 amount, bytes calldata data) external;
   function downgrade(uint256 amount) external;
   
   /**************************************************************************
   * Batch Operations
   *************************************************************************/
   
   function operationApprove(
        address account,
        address spender,
        uint256 amount
   ) external;
   function operationTransferFrom(
        address account,
        address spender,
        address recipient,
        uint256 amount
   ) external;
   function operationUpgrade(address account, uint256 amount) external;
   function operationDowngrade(address account, uint256 amount) external;
   
}