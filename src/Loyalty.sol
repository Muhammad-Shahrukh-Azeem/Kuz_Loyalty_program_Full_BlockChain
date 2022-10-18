// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
contract Loyalty is Ownable{

    uint256 internal loyaltyPercentage = 1000; // This is 10% in BIPS

    event LoyaltyUpdated(uint256 loyaltyPercentageBefore, uint256 loyaltyPercentageAfter);

    /**
     * @notice Method setting and Updating LoyaltyPercenrage
     * @param _loyaltyPercentage new listing Percentage in BIPS
     */

    function setLoyaltyPercentage(uint256 _loyaltyPercentage) external onlyOwner {
        emit LoyaltyUpdated(loyaltyPercentage, _loyaltyPercentage);
        loyaltyPercentage = _loyaltyPercentage;
    }

    /**
     * @notice Method for calculating rewards for tokens 
     * @param _cost Takes in purchases in uint to calculate royalty tokens to mint
     */
    function calculateLoyalty(uint _cost) internal view returns(uint){
        return ((_cost * loyaltyPercentage) / 10000);
    }

    function getLoyaltyPercentage() public view returns(uint){
        return loyaltyPercentage;
    }
    
}
