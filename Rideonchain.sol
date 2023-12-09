// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Rideonchain {
    address public owner;

    mapping(address => uint256) public amountsOwed; // Mapping to store amounts owed to drivers

    event PaymentSent(address indexed from, address indexed to, uint256 amount);
    event PaymentClaimed(address indexed driver, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }

    function setAmountOwed(address driver, uint256 amount) external onlyOwner {
        amountsOwed[driver] = amount;
    }

    function makePayment(address driver) external payable {
        require(msg.value > 0, "Amount must be greater than zero.");
        require(amountsOwed[driver] == msg.value, "Incorrect amount specified for the driver.");
        
        payable(driver).transfer(msg.value); // Transfer Ether to the driver
        emit PaymentSent(msg.sender, driver, msg.value);
        amountsOwed[driver] = 0; // Reset the owed amount to zero after payment
    }

    function claimPayment() external {
        uint256 amountOwed = amountsOwed[msg.sender];
        require(amountOwed > 0, "No amount owed to the caller.");
        
        payable(msg.sender).transfer(amountOwed); // Transfer owed amount to the driver
        emit PaymentClaimed(msg.sender, amountOwed);
        amountsOwed[msg.sender] = 0; // Reset the owed amount to zero after claiming
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient contract balance.");
        payable(owner).transfer(amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}