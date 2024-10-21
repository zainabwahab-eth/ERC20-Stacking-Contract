// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27; // stating version type

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract StakingContract {
    using SafeERC20 for IERC20;

    IERC20 public stakingToken;
    IERC20 public rewardToken;
    uint256 public rewardRate = 1000; 
    uint256 public totalTokenStaked = 0;

    mapping(address => uint256) tokenStaked;
    mapping(address => uint256) lastUpdated;
    mapping(address => uint256) claimed;

    event StakeSuccessful(address indexed user, uint256 amount);
    event WithdrawSuccessful(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(IERC20 _stakingToken, IERC20 _rewardToken) {
        stakingToken = _stakingToken;
        rewardToken = _rewardToken;
    }

    // Stake function. To allow users deposit and stake token in this contract
    function stake(uint256 _amount) external {
        require(_amount > 0, "Can't deposit zero value");
        require(msg.sender != address(0), "zero address dectected");

        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        tokenStaked[msg.sender] += _amount;
        totalTokenStaked += _amount;
        lastUpdated[msg.sender] = block.timestamp;

        emit StakeSuccessful(msg.sender, _amount);
    }

    // Function to calculate and return the reward of an address
    function calculateReward(address user) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastUpdated[user];
        return (tokenStaked[user] * timeElapsed) / rewardRate;
    }

    // Function to claim reward. When a user claim it is sent to the account.
    function claimReward() external {
        uint256 _amount = calculateReward(msg.sender);
        require(_amount > 0, "No rewards available");

        rewardToken.safeTransfer(msg.sender, _amount);
        claimed[msg.sender] += _amount;
        lastUpdated[msg.sender] = block.timestamp;

        emit RewardClaimed(msg.sender, _amount);
    }

    // Function to withdraw token
    function withdraw(uint256 _amount) external {
        require(_amount > 0 && _amount <= tokenStaked[msg.sender], "Invalid amount");
        require(msg.sender != address(0), "zero address dectected");

        tokenStaked[msg.sender] -= _amount;
        totalTokenStaked -= _amount;
        lastUpdated[msg.sender] = block.timestamp;

        stakingToken.safeTransfer(msg.sender, _amount);

        emit WithdrawSuccessful(msg.sender, _amount);
    }

    function getRewardToken() external view returns (uint256) {
        return rewardToken.balanceOf(address(this));
    }

    //function to get a contract token balance
    function getContractBalance() external view returns (uint256) {
        return totalTokenStaked;
    }

    // function to get the user balance
    function getUserBalance() external view returns (uint256) {
        return tokenStaked[msg.sender];
    }

    // function to get the user claimed balance
    function getClaimedBalance() external view returns (uint256) {
        return claimed[msg.sender];
    }   
}