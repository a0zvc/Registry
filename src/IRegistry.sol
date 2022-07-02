pragma solidity >=0.8.0;


interface IRegistry {

    /// @notice sets external contract addresses.
    /// @param _router: UniV2 router address
    /// @param _factory: UniV2 factory address
    /// @param _reliableERC20 third party ERC20 (DAI/USDC etc.) used for value determinations
    /// @param _tributeShare share of totalsupply as value contribution. 100 for 1%
    /// @param _reliableAmt sender approved amount to add as initial liquidity at pool formation
    /// @param _a0zAmount amount to mint and add as initial liquidity at pool formation
    function setExternalPoints(address _router, address _factory, address _reliableERC20, uint256 _tributeShare,  uint256 _reliableAmt, uint256 _a0zAmount) external returns (address);

    /// @notice authorizes msg.sender as Deal constructor on the basis of configured conditions
    /// @param _parentToken ERC20 unit of Parent value. Will be paired with children tokens in LP nexus
    /// @param pool address of Registry-Parent
    function selfRegister(address _parentToken) external returns (address pool);

    /// @notice returns the address of registry-parenty pool address. can be used to establish deal minting authority
    /// @param _OfSender address to check if it has registered pool
    function getParentPool(address _OfSender) external view returns (address);

    /// @notice returns the address of third token
    function opTokenAddress() external view returns (address);

    /// @notice returns minimum amount of thirdToken() needed to be approved for selfRegister()
    function calculateInitValue() external view returns (uint256);
}