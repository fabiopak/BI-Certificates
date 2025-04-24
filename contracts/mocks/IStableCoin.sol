// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IStableCoin {
    function transferAddresses(address addr) external view returns (bool);
    function mintCoins(address to, uint256 amount) external;
    function forcedBurnCoins(address account, uint256 amount) external;
    function batchForcedBurnCoins(address[] calldata account, uint256[] calldata amount) external;
}