// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "remix_tests.sol"; // Auto-included by Remix for testing
import "../contracts/KipuBank.sol"; // adjust the path if needed

contract KipuBankTest {
    KipuBank kipu;
    address user = address(this);

    /// #value: 0
    function beforeAll() public {
        // Deploy contract with BANK_CAP = 10 ether, MAX_WITHDRAW_PER_TX = 1 ether
        kipu = new KipuBank(10 ether, 1 ether);
    }

    /// Check deposit of 1 ether works
    /// #value: 1000000000000000000
    function testDepositSuccess() public payable {
        uint256 balanceBefore = kipu.getBalance(user);
        kipu.deposit{value: 1 ether}();
        uint256 balanceAfter = kipu.getBalance(user);
        Assert.equal(balanceAfter, balanceBefore + 1 ether, "Balance should increase by 1 ether");
    }

    /// Check deposit fails if value is 0
    function testDepositZeroReverts() public {
        try kipu.deposit{value: 0}() {
            Assert.ok(false, "Deposit with 0 should revert");
        } catch Error(string memory reason) {
            Assert.ok(false, string(abi.encodePacked("Unexpected revert reason: ", reason)));
        } catch (bytes memory) {
            Assert.ok(true, "Deposit with 0 reverted as expected (custom error)");
        }
    }

    /// Check withdraw works with correct amount
    function testWithdrawSuccess() public {
        // Withdraw 0.5 ether (should work if we already deposited >= 1 ether)
        kipu.withdraw(0.5 ether);
        uint256 remainingBalance = kipu.getBalance(user);
        Assert.equal(remainingBalance, 0.5 ether, "Remaining balance should be 0.5 ether");
    }

    /// Check withdraw reverts if exceeds max per tx
    function testWithdrawExceedsMaxPerTx() public {
        uint256 tooMuch = 2 ether; // > MAX_WITHDRAW_PER_TX (1 ether)
        try kipu.withdraw(tooMuch) {
            Assert.ok(false, "Withdraw > MAX_WITHDRAW_PER_TX should revert");
        } catch Error(string memory reason) {
            Assert.ok(false, string(abi.encodePacked("Unexpected revert reason: ", reason)));
        } catch (bytes memory) {
            Assert.ok(true, "Withdraw exceeding max per tx reverted as expected (custom error)");
        }
    }
}
