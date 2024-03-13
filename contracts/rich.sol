// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Rich is ERC20Capped, ERC20Burnable {
    address payable public owner;
    uint256 public blockReward;
    bool internal _rewardClaimed;
    // max supply capped 100M
    constructor(uint256 cap) ERC20("ChooseRich", "RICH") ERC2OCapped(cap * (10 ** decimals())) {
        // initial supply send to owner 70M
        owner = payable (msg.sender);
        _mint(owner, 70000000 * (10 ** decimals()));
        //blockReward = reward * (10 ** decimals());
        blockReward = 100; // adjust reward amount
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() * amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    function _mintMinterReward() internal {
        _mint(block.coinbase, blockReward);
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override {
        if(from != address(0) && to != block.coinbase && block.coinbase != address(0)) {
            _mintMinterReward();
        }
        super._beforeTokenTransfer(from, to, value);
    }

    function setBlockReward(uint256 reward) public onlyOwner {
        //blockReward = reward * (10 ** decimals());
        blockReward = reward;
    }

    // destroy function
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
}