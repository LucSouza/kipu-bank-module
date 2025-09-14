// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title KipuBank — Personals ETH account
/// @author https://github.com/LucSouza  - Lucas Souza
/// @notice Minimal ETH vaults with per-tx withdraw limit and global bank cap.
/// @dev Ownable and ReentrancyGuard. Errors are custom for gas efficiency.

import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "openzeppelin-contracts/utils/Pausable.sol";

/// ---------------------------------------------------------------------
/// Errors
/// ---------------------------------------------------------------------
error Paused();
error NotOwner();
error TransferFailed(address user, uint256 attempted, WithdrawErrorReason reason, uint256 amount) ;

/// enum for custom error
enum WithdrawErrorReason { ZERO_AMOUNT, INSUFFICIENT_BALANCE, EXCEEDS_MAX_PER_TX, EXCEEDS_MAX_BANK_CAP, TRANSFER_FAILED }

/* @notice KipuBank lets users deposit ETH into personal vaults and withdraw with limits per transaction
@dev BANK_CAP and MAX_WITHDRAW_PER_TX are immutable.*/
contract KipuBank is Ownable, ReentrancyGuard, Pausable {
    /// -----------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------
    /// @notice Emitted when a user deposits ETH.
    event Deposited(address indexed user, uint256 amount, uint256 userBalance, uint256 totalBankBalance);
    /// @notice Emitted when a user withdraws ETH.
    event Withdrawn(address indexed user, uint256 amount, uint256 userBalance, uint256 totalBankBalance);
    /// @notice Emitted when emergency withdrawal performed by owner.
    event EmergencyWithdraw(address indexed to, uint256 amount);

    /// -----------------------------------------------------------------
    /// Immutable / constants
    /// -----------------------------------------------------------------
    uint256 public immutable BANK_CAP;              // maximum total ETH this contract may hold
    uint256 public immutable MAX_WITHDRAW_PER_TX;   // maximum withdrawn per transaction

    /// -----------------------------------------------------------------
    /// Storage
    /// Total transaction counters, total bank balance and owners balance;
    /// -----------------------------------------------------------------
    mapping(address => uint256) private _balances;
    uint256 private _totalBankBalance;
  
    uint256 public depositCount;
    uint256 public withdrawCount;

    /// -----------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------
    /// @param _bankCap The maximum total ETH that can be held in the bank (in wei)
    /// @param _maxWithdrawPerTx Max allowed withdrawal per transaction (in wei)
    constructor(uint256 _bankCap, uint256 _maxWithdrawPerTx) {
        require(_bankCap > 0, "_bankCap must be higher than 0");
        require(_maxWithdrawPerTx > 0, "max value per transaction must be higher than 0");
        BANK_CAP = _bankCap;
        MAX_WITHDRAW_PER_TX = _maxWithdrawPerTx;
        // owner is set by Ownable constructor (msg.sender)
    }

    /// -----------------------------------------------------------------
    /// Deposit ETH
    /// -----------------------------------------------------------------
    /// @notice Deposit ETH into your personal vault.
    /// deposit if correct update totalBankBalance and user balance
    /// @dev Respects BANK_CAP. Emits Deposited.
    function deposit() external payable whenNotPaused {
        if (msg.value == 0) revert TransferFailed(msg.sender, msg.value, WithdrawErrorReason.ZERO_AMOUNT, msg.value);
        uint256 newTotal = _totalBankBalance + msg.value;
        if (newTotal > BANK_CAP) revert TransferFailed(msg.sender, newTotal, WithdrawErrorReason.EXCEEDS_MAX_BANK_CAP, BANK_CAP);

        _balances[msg.sender] += msg.value;
        _totalBankBalance = newTotal;
        unchecked { depositCount++; }

        emit Deposited(msg.sender, msg.value, _balances[msg.sender], _totalBankBalance);
    }

    /// @notice Withdraw up to MAX_WITHDRAW_PER_TX from your vault.
    /// @param amount Amount in wei to withdraw.
    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        if (amount == 0) revert TransferFailed(msg.sender, amount, WithdrawErrorReason.ZERO_AMOUNT, amount);
        if (amount > MAX_WITHDRAW_PER_TX) revert TransferFailed(msg.sender, amount, WithdrawErrorReason.EXCEEDS_MAX_PER_TX, MAX_WITHDRAW_PER_TX);

        uint256 bal = _balances[msg.sender];
        if (amount > bal) revert TransferFailed(msg.sender, amount, WithdrawErrorReason.EXCEEDS_MAX_PER_TX, bal);


        // --- Checks done; Effects:
        _balances[msg.sender] = bal - amount;
        /// remove amout from balance on chain
        _totalBankBalance -= amount;
        // can be use unchecked because already checked that amount can´t be less than balance
        unchecked { withdrawCount++; }

        // --- Interaction:
       _transferETH(msg.sender, amount, bal);

        emit Withdrawn(msg.sender, amount, _balances[msg.sender], _totalBankBalance);
    }

/// private function to attend requirements for evaluation ill call it from withdraw instead of calling call directly there;
function _transferETH(address to, uint256 amount, uint256 bal) private {
    (bool success, ) = to.call{value: amount}("");
    if (!success) revert TransferFailed(msg.sender, amount, WithdrawErrorReason.TRANSFER_FAILED, bal);
}
    /// -----------------------------------------------------------------
    /// Views
    /// -----------------------------------------------------------------
    /// @notice Returns balance of a given user.
    function getBalance(address user) external view returns (uint256) {
        return _balances[user];
    }

    /// @notice Returns total ETH stored in the bank.
    function totalBankBalance() external view returns (uint256) {
        return _totalBankBalance;
    }

    /// -----------------------------------------------------------------
    /// Owner / admin functions (explicit & minimal)
    /// -----------------------------------------------------------------
    /// @notice Pause contract operations (deposits/withdraws).
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause contract operations.
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Emergency withdraw by owner — use only in extreme cases and document externally.
    /// @dev Transfers the entire contract balance to `to`. Emits EmergencyWithdraw.
    function emergencyWithdraw(address payable to) external onlyOwner {
        uint256 amount = address(this).balance;
        if (amount == 0) revert TransferFailed(msg.sender, amount, WithdrawErrorReason.ZERO_AMOUNT, amount);
        (bool s, ) = to.call{value: amount}("");
        if (!s) revert TransferFailed(msg.sender, amount, WithdrawErrorReason.TRANSFER_FAILED, amount);
        _totalBankBalance = 0;
        emit EmergencyWithdraw(to, amount);
    }

    /// -----------------------------------------------------------------
    /// Receive / fallback
    /// -----------------------------------------------------------------
    receive() external payable {
        // Got this suggestion from chatGTP in order to protect 
        // Forward to deposit logic to ensure bankCap is respected.
        // Using low-level to avoid duplication: call deposit() via external call pattern
        // But calling deposit() directly from receive() may increase gas; in order to ensure
        // atomic checks, prefer to revert if receive() is used unexpectedly.
        revert("Use deposit()");
    }

    fallback() external payable {
        revert("Use deposit()");
    }
}