// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityToken is ERC20, ERC20Burnable, Ownable {
    constructor(string memory tokenName, string memory tokenSymbol, address initialOwner) ERC20(tokenName, tokenSymbol) Ownable(initialOwner) {}

    receive() external payable {
        revert();
    }
    
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
