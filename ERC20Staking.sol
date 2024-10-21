// SPDX-License-Identifier: MIT
pragma solidity 0.8.27; // stating version type

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ERC20Stacking{

    using SafeERC20 for IERC20;

    IERC20 public token;

    uint256 public totalTokenStaked = 0;

    uint256 public rewardRate = 1000;

    // mapping of tokenStaked
    mapping(address => uint256) tokenStaked;

    // mapping to track the last time a user interacted with the contract
    mapping(address => uint256) lastUpdated;

    // mapping of Calimed token
    mapping(address => uint256) claimed;

    event DepositSuccessful(address indexed user, uint256 amount);
    event ClaimSuccessful(address indexed user, uint256 amount);
    event WithdrawSuccessful(address indexed user, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
    }


    // Deposit function. To allow users deposit token to this contract
    function Deposit(uint256 _amount) external {
        require(_amount > 0, "Can't deposit zero value");
        require(msg.sender != address(0), "zero address dectected");

        token.safeTransferFrom(msg.sender, address(this), _amount);
        tokenStaked[msg.sender] += _amount;
        totalTokenStaked += _amount;
        lastUpdated[msg.sender] = block.timestamp;
        
        emit DepositSuccessful(msg.sender, _amount);
    }

    // Function to calculate and return the reward of an address
    function reward(address _userAddress) public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - lastUpdated[_userAddress];
        return (tokenStaked[_userAddress] * timeElapsed) / rewardRate;
    }

    // Function to claim reward. When a user claim it is sent to the account.
    function claim() external {
        uint256 _amount = reward(msg.sender);
        
        claimed[msg.sender] += _amount;
        lastUpdated[msg.sender] = block.timestamp;

        token.safeTransfer(msg.sender, _amount);
        emit ClaimSuccessful(msg.sender, _amount);
    }

    // Function to withdraw token
    function withdraw(uint256 _amount) external{
        require(_amount > 0, "Can't Withdrew zero value");
        require(msg.sender != address(0), "zero address dectected");

        uint256 userToken = tokenStaked[msg.sender];
        require(_amount <= userToken, "insufficient funds");

        tokenStaked[msg.sender] -= _amount;
        totalTokenStaked -= _amount;
        lastUpdated[msg.sender] = block.timestamp;

        token.safeTransfer(msg.sender, _amount);
        emit WithdrawSuccessful(msg.sender, _amount);
    }

    // function to get the amount of reward tokens we have
    function getRewardToken() external view returns (uint256) {
        return token.balanceOf(address(this)) - totalTokenStaked;
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