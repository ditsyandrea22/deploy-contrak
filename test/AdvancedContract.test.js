const AdvancedContract = artifacts.require("AdvancedContract");

contract("AdvancedContract", (accounts) => {
  let contract;
  const [owner, user1, user2] = accounts;

  beforeEach(async () => {
    contract = await AdvancedContract.new({ from: owner });
  });

  it("should deposit and update balances correctly", async () => {
    const depositAmount = web3.utils.toWei("1", "ether");
    await contract.deposit({ from: user1, value: depositAmount });
    
    const userBalance = await contract.balances(user1);
    const contractBalance = await contract.contractBalance();
    
    assert.equal(userBalance.toString(), depositAmount, "User balance incorrect");
    assert.equal(contractBalance.toString(), depositAmount, "Contract balance incorrect");
  });

  it("should prevent reentrancy attacks", async () => {
    // Deploy malicious contract that tries to reenter
    const MaliciousContract = artifacts.require("MaliciousContract");
    const malicious = await MaliciousContract.new(contract.address, { from: user1 });
    
    // Deposit to malicious contract
    const depositAmount = web3.utils.toWei("1", "ether");
    await malicious.deposit({ from: user1, value: depositAmount });
    
    try {
      await malicious.attack({ from: user1 });
      assert.fail("Expected revert not received");
    } catch (error) {
      assert.include(error.message, "revert", "Expected revert");
    }
  });

  it("should only allow owner to emergency withdraw", async () => {
    try {
      await contract.emergencyWithdraw({ from: user1 });
      assert.fail("Expected revert not received");
    } catch (error) {
      assert.include(error.message, "Not owner", "Expected owner restriction");
    }
  });

  it("should stop in emergency mode", async () => {
    await contract.toggleContractActive({ from: owner });
    const depositAmount = web3.utils.toWei("1", "ether");
    
    try {
      await contract.deposit({ from: user1, value: depositAmount });
      assert.fail("Expected revert not received");
    } catch (error) {
      assert.include(error.message, "Contract is stopped", "Expected stopped contract");
    }
  });
});