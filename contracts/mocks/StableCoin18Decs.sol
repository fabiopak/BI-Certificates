// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {AccessControlEnumerable} from "@openzeppelin/contracts/access/extensions/AccessControlEnumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IStableCoin} from "./IStableCoin.sol";
import {IRHErrors} from "../interfaces/IRHErrors.sol";

contract StableCoin18Decs is Ownable, ERC20, ERC20Burnable, AccessControlEnumerable, Pausable, IRHErrors, IStableCoin {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    // bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public maxArrayLength;

    /// @dev contractAddress => boolean
    mapping(address => bool) public override transferAddresses;

    constructor(string memory _name, string memory _sym) ERC20(_name, _sym) Ownable(msg.sender) { 
        maxArrayLength = 100;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
    }

    /**
     * @dev set new max array length for txs (DEFAULT_ADMIN_ROLE)
     * @param _newLen new max array length
     */
    function setMaxArrayLen(uint256 _newLen) external onlyRole(ADMIN_ROLE){
        maxArrayLength = _newLen;
    }

    /**
     * @dev single mint (ADMIN_ROLE, check performed by inherited contract)
     * @param to recipient address
     * @param amount amount to be minted
     */
    function mintCoins(address to, uint256 amount) external onlyRole(ADMIN_ROLE) {
        super._mint(to, amount);
    }

    /**
     * @dev batch mint (ADMIN_ROLE, check performed by inherited contract)
     * @param to recipient address array 
     * @param amount amount to be minted array
     */
    function batchMintCoins(address[] calldata to, uint256[] calldata amount) external onlyRole(ADMIN_ROLE) {
        if (to.length != amount.length || to.length > maxArrayLength) {
            revert invalidArrayLength();
        }

        for (uint256 i = 0; i < to.length; i++) {
            if (amount[i] > 0) {
                super._mint(to[i], amount[i]);
            }
        }   
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        if (from != address(0) && to!= address(0) && !transferAddresses[from] && !transferAddresses[to] ) {
            revert notTransferrable();
        } /*else if (to!= address(0)){
            approve(to, value);
        }*/

        super._update(from, to, value);
    }

    /**
     * @dev set transfer address (DEFAULT_ADMIN_ROLE)
     * @param allowedAddress address to be allowed
     */
    function setTransferAddress(address allowedAddress) external onlyRole(ADMIN_ROLE){
        transferAddresses[allowedAddress] = true;
    }

    /**
     * @dev forced burn (ADMIN_ROLE)
     * @param account address where token has to be burned
     * @param amount amount of tokens to be burned
     */
    function forcedBurnCoins(address account, uint256 amount) external onlyRole(ADMIN_ROLE){
        super._burn(account, amount);
    }

    /**
     * @dev batch forced burn (ADMIN_ROLE)
     * @param account address array where token has to be burned
     * @param amount amount array of tokens to be burned
     */
    function batchForcedBurnCoins(address[] calldata account, uint256[] calldata amount) external onlyRole(ADMIN_ROLE) {
        if (account.length != amount.length || account.length > maxArrayLength) {
            revert invalidArrayLength();
        }

        for (uint256 i = 0; i < account.length; i++) {
            if (amount[i] > 0) {
                super._burn(account[i], amount[i]);
            }
        }   
    }
    
    /**
     * @dev pause this contract (ADMIN_ROLE)
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        super._pause();
    }

    /**
     * @dev unpause this contract (ADMIN_ROLE)
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        super._unpause();
    }
}
