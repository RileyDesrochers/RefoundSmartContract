// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RefoundUSD is ERC20 {
    mapping(address => uint256) available;

    IERC20 token;

    mapping(address => address) beneficiary;
    mapping(address => bool) fundsBeingClaimed;
    mapping(address => uint256) beneficiaryClaimTimestamp;

    uint256 accountLockPeriod = 60*60*24*7; 

    modifier accountNotLocked(address user) {
        require(!fundsBeingClaimed[user], 'this account is being claimed');
        _;
   }

    constructor(address _token) ERC20("RefoundUSD", "RUSD") {
        token = IERC20(_token);
    }

    function deposit(uint256 amount) public accountNotLocked(msg.sender) {
        token.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function withdrawal(uint256 amount) public accountNotLocked(msg.sender) {
        _burn(msg.sender, amount);
        token.transfer(msg.sender, amount);
    }

    function setBeneficiary(address _beneficiary) public {
        beneficiary[msg.sender] = _beneficiary;
    }

    function startBeneficiaryClaimFunds(address user) public accountNotLocked(user) {
        require(beneficiary[user] == msg.sender, 'this user has not made you his beneficiary');

        fundsBeingClaimed[user] = true; 
        beneficiaryClaimTimestamp[user] = block.timestamp + accountLockPeriod;
    }

    function beneficiaryClaimFunds(address user) public accountNotLocked(user) {
        require(beneficiary[user] == msg.sender, 'this user has not made you his beneficiary');
        require(fundsBeingClaimed[user] == true, 'you need to use startBeneficiaryClaimFunds first');
        require(beneficiaryClaimTimestamp[user] < block.timestamp, 'you need to wait till LockPeriod is over');
        
        //FIX unlock all locked tokens

        uint256 amount = balanceOf(user);
        _burn(user, amount);
        token.transfer(user, amount);
    }

    function openChannel() public {

    }

    function startCancelChannel() public {
        
    }

    function cancelChannel() public {
        
    }

    function payeeChannel() public {
        
    }

    /*
    function availableOf(address account) public view retuens(uint256){

    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }
    */
}