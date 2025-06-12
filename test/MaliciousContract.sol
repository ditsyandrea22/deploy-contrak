// contracts/test/MaliciousContract.sol
pragma solidity ^0.8.0;

interface IAdvancedContract {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

contract MaliciousContract {
    IAdvancedContract public target;
    bool private attacking = false;
    
    constructor(address _target) {
        target = IAdvancedContract(_target);
    }
    
    function deposit() external payable {
        target.deposit{value: msg.value}();
    }
    
    function attack() external {
        attacking = true;
        target.withdraw(1 ether);
        attacking = false;
    }
    
    receive() external payable {
        if (attacking) {
            target.withdraw(1 ether);
        }
    }
}