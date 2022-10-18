// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../node_modules/@openzeppelin/contracts/security/Pausable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract PhoneBotToken is ERC20, ERC20Burnable, Pausable, Ownable {

    mapping(address => bool) public  teamAccessRecord;

    modifier onlyTeam() {
        require(teamAccessRecord[msg.sender], "You are not part of team");
        _;
    }

    constructor() ERC20("PhoneBotToken", "PBT") {
        _mint(msg.sender, 100 * 10**decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyTeam {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function transfer(address to, uint256 _amount)
        public
        virtual
        override
        returns (bool)
    {
        revert("No Monkey Bussiness");
        return true;
    }

    function transferFrom(address from, address to, address amount) public virtual  returns(bool){
        revert("Nice Try, Still no monkey bussiness");
        return true;
    }
}
