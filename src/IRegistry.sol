pragma solidity >=0.8.0;


interface IRegistry {

    /// @notice sets external contract addresses.
    /// @param _router: UniV2 router address
    /// @param _factory: UniV2 factory address
    /// @param _reliableERC20 third party ERC20 (DAI/USDC etc.) used for value determinations
    function setExternalPoints(address _router, address _factory, address _reliableERC20) external returns (bool);

    /// @notice authorizes msg.sender as Deal constructor on the basis of configured conditions
    /// @param _parentToken ERC20 unit of Parent value. Will be paired with children tokens in LP nexus
    /// @param pool address of Registry-Parent
    function selfRegister(address _parentToken) external returns (address pool);


}