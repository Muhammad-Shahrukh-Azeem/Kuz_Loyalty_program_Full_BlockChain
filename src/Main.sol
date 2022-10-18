// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "./Loyalty.sol";
import "./Fee.sol";
import "./PhoneBotToken.sol";

// The name Main will be changed to the project name
contract Main is Fee, Loyalty, PhoneBotToken {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public lockTIme;
    address internal taxCollector;

    error alreadyAdded();
    error invalidInputParams();
    error invalidAddress();
    error cannotBeZero();
    error decreaseNumberOfAddresses();
    error notCustomersWallet();
    error NotTheOwner();
    error AlreadyRedeemed();
    error NotUnlockedYet();
    error ProductRefunded();
    error NotEnoughBalance();
    error cannotBeContract();
    error AlreadyAdded();

    event TokenRewarded(
        address user,
        uint256 purchaseAmount,
        uint256 tokensEarned,
        uint256 timeOfPurchase,
        uint256 lockTime,
        bool tokensRedeemed,
        bool refunded
    );

    event TokensClaimeded(
        address user,
        uint256 tokensEarned,
        bool tokensRedeemed
    );

    event TokensBurned(uint256 amount, address user);
    // This struct will hold all relevent Data;
    struct PurchaseData {
        address user;
        uint256 purchaseAmount;
        uint256 tokensEarned;
        uint256 timeOfPurchase;
        uint256 lockTime;
        bool tokensRedeemed;
        bool refunded;
    }

    // Mapping hold id to struct data
    mapping(uint256 => PurchaseData) public purchaseRecord;

    // Team Addresses
    // mapping(address => bool) internal teamAccessRecord;

    mapping(address => bool) internal customerWallets;

    // // This is to restrict members from accessing mint function
    // modifier onlyTeam() {
    //     require(teamAccessRecord[msg.sender], "You are not part of team");
    //     _;
    // }

    /**
     * @notice Method for setting locking period
     * @param _time Address of team member
     */
    function setLockedPeriod(uint256 _time) external onlyOwner {
        uint256 daysToTime = (_time * 84600);
        lockTIme = daysToTime;
    }

    /**
     * @notice Method for adding WL to customers
     * @param _customer Address of team member
     */
    function addCustomnerWallet(address _customer) external onlyTeam {
        if (_customer == address(0)) {
            revert invalidAddress();
        }
        if (customerWallets[_customer]) {
            revert alreadyAdded();
        }

        customerWallets[_customer] = true;
    }

    /**
     * @notice Method for security to ensure that address is not of a contract
     * @param _addr input address
     */
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    /**
     * @notice Method for adding team members
     * @param _member Address of team member
     */
    function addTeamAddress(address _member) external onlyOwner {
        if (teamAccessRecord[_member]) {
            revert AlreadyAdded();
        }
        teamAccessRecord[_member] = true;
    }

    /**
     * @notice Method for adding _taxCollector
     * @param _taxCollector Address of treasy where fee will be collected
     */
    function setTaxCollector(address _taxCollector) external onlyOwner {
        if (isContract(_taxCollector)) {
            revert cannotBeContract();
        }
        taxCollector = _taxCollector;
    }

    /**
     * @notice Method for removing team members
     * @param _member Address of team member
     */
    function removeMemberAddress(address _member) external onlyOwner {
        teamAccessRecord[_member] = false;
        delete teamAccessRecord[_member];
    }

    /**
     * @notice Method for setting reward to buyers
     * @param _user Address of buyer
     * @param _basketSize The amount that he purchased
     */
    function setLoyaltyTokensEarned(address _user, uint256 _basketSize)
        external
        onlyTeam
    {
        if (!customerWallets[_user]) {
            revert notCustomersWallet();
        }
        if (_user == address(0)) {
            revert invalidAddress();
        }
        if (_basketSize <= 0) {
            revert cannotBeZero();
        }
        uint256 orderId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        uint256 rewardSize = calculateLoyalty(_basketSize);

        purchaseRecord[orderId] = PurchaseData(
            _user,
            _basketSize,
            rewardSize,
            block.timestamp,
            (block.timestamp + lockTIme),
            false,
            false
        );

        emit TokenRewarded(
            _user,
            _basketSize,
            rewardSize,
            block.timestamp,
            (block.timestamp + lockTIme),
            false,
            false
        );
    }

    // this function's input will be send through backed web; when the user presses claim button they will recieve these tokens in their phonebot wallet
    function claimTokensInWallet(uint256 _id, address _user) external onlyTeam {
        if (purchaseRecord[_id].user != _user) {
            revert NotTheOwner();
        }
        if (purchaseRecord[_id].tokensRedeemed) {
            revert AlreadyRedeemed();
        }
        if (purchaseRecord[_id].lockTime > block.timestamp) {
            revert NotUnlockedYet();
        }
        if (purchaseRecord[_id].refunded) {
            revert ProductRefunded();
        }
        uint256 rewardAmount = purchaseRecord[_id].tokensEarned;

        purchaseRecord[_id].tokensRedeemed = true;

        mint(_user, rewardAmount);

        emit TokensClaimeded(_user, rewardAmount, true);
    }

    // CALL_SPENDALLOWANCE BEFORE CALLING THIS FUNCTION
    function burnOnPurchase(uint256 _amount, address _user) external onlyTeam {
        if (balanceOf(_user) < _amount) {
            revert NotEnoughBalance();
        }
        burnFrom(_user, _amount);
        emit TokensBurned(_amount, _user);
    }

    //MAKE A BURN FUNCTION ON CLAIM .... THE ABOVE FUNCTION

    // /**
    //  * @notice Method for minting for users
    //  * @param tokenHolders Array of Address where to transfer
    //  * @param amounts The amount that is to be minted
    //  */
    // function batchMint(
    //     address[] calldata tokenHolders,
    //     uint256[] calldata amounts
    // ) internal {
    //     if (tokenHolders.length > 600){
    //         revert decreaseNumberOfAddresses();
    //     }
    //     if (tokenHolders.length != amounts.length) {
    //         revert invalidInputParams();
    //     }
    //     for (uint256 i = 0; i < tokenHolders.length; i++) {
    //         mint(tokenHolders[i], amounts[i]);
    //     }
    // }

    // This transfer function still needs a check inside it to prevent it from sending on certain conditions
    function transferingTokensOutside(address to, uint256 _amount)
        internal
        returns (bool)
    {
        uint256 amount = calculateAfterfeeDeduction(_amount);
        address sender = _msgSender();
        _transfer(sender, to, amount);
        return true;
    }

    function getLockedTime() public view returns (uint256) {
        return (lockTIme / 84600);
    }

    function getIsTeamMember(address _team) public view returns (bool) {
        return teamAccessRecord[_team];
    }

    function getIsCustomerWL(address _customer) public view returns (bool) {
        return customerWallets[_customer];
    }

    function getTaxCollectorAddress()
        external
        view
        onlyOwner
        returns (address)
    {
        return taxCollector;
    }
}

// function batchMint(
//     // address[] calldata tokenHolders,
//     // uint256[] calldata amounts
// ) external onlyOwner {
//     require(
//         testAddresses.length == tokenValues.length,
//         "Invalid input parameters"
//     );

//     for (uint256 i = 0; i < testAddresses.length; i++) {
//         mint(testAddresses[i], tokenValues[i]);
//         // emit sucessfullyTransferredTo(tokenHolders[i], amounts[i]);
//     }
// }

// address[] public testAddresses;
// uint256[] public tokenValues;

// function setUp() public {
//     // vm.startPrank(address(1));
//     // main = new Main();

//     for (uint256 i = 2; i < 1203; i++) {
//         testAddresses.push(address(5));
//         tokenValues.push(1000);
//     }
// }
