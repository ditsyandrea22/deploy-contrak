// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AdvancedContract is ReentrancyGuard {
    using SafeMath for uint256;
    
    address payable public owner;
    uint256 public contractBalance;
    mapping(address => uint256) public balances;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be positive");
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        contractBalance = contractBalance.add(msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(address(this).balance >= amount, "Contract has insufficient funds");
        
        balances[msg.sender] = balances[msg.sender].sub(amount);
        contractBalance = contractBalance.sub(amount);
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }

    function emergencyWithdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        owner.transfer(balance);
        contractBalance = 0;
    }

    // Additional security: Circuit breaker pattern
    bool public stopped = false;
    
    modifier stopInEmergency { 
        require(!stopped, "Contract is stopped"); 
        _; 
    }
    
    function toggleContractActive() public onlyOwner {
        stopped = !stopped;
    }
}