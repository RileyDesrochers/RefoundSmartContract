// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract RefoundUSD is ERC20 {
    //mapping(address => uint256) locked;

    IERC20 token;

    mapping(address => address) beneficiary;
    mapping(address => bool) fundsBeingClaimed;
    mapping(address => uint256) beneficiaryClaimTimestamp;

    uint256 accountLockPeriod = 60*60*24*7;
    uint256 subscriptionPeriod = 60*60*24*30;
    uint256 subscriptionAmount = 5*(10**18);
    uint256 subsciptionStartTime;
    address owner;
    address[] subsciptionRecivers;
    mapping(address => bool) subsciptionReciversMap;
    mapping(address => address[]) subscriptions;//Reciver to payee
    mapping(address => mapping(address => bool)) subsciptionReciversCanClaimPayment;//Reciver, Payee to can funds be claimed

    uint256 subsciptionReciverInedx;
    uint256 subscriptionsInedx;
    bool SubsciptionsLocked;

    modifier accountNotLocked(address user) {
        require(!fundsBeingClaimed[user], 'this account is being claimed');
        _;
   }

    constructor(address _token) ERC20("RefoundUSD", "RUSD") {
        token = IERC20(_token);
        subsciptionStartTime = block.timestamp;
        owner = msg.sender;
        subsciptionReciverInedx = 0;
        subscriptionsInedx = 0;
        SubsciptionsLocked = false;
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

    function cancelClaim() public {
        fundsBeingClaimed[msg.sender] = false;
    }

    function addSubsciptionReciver(address reciver) public {
        require(subsciptionReciversMap[msg.sender] == false);
        require(!SubsciptionsLocked);
        subsciptionReciversMap[msg.sender] == true;
        subsciptionRecivers.push(reciver);
    }

    function subscribe(address reciver) public {
        require(subsciptionReciversMap[msg.sender] == true, "this user need to call addSubsciptionReciver for you to subscribe to them");
        require(!SubsciptionsLocked);
        //transfer(reciver, subscriptionAmount);//pay amount for this subscription period
        subscriptions[reciver].push(msg.sender);
    }

    function unSubscribe(address reciver, uint64 index) public {
        require(!SubsciptionsLocked);
        require(subscriptions[reciver][index] ==  msg.sender);
        subscriptions[reciver][index] = address(0);
    }

    function incrementSubsciptionPeriod() public {
        require(msg.sender == owner);
        require(SubsciptionsLocked);
        require(subsciptionReciverInedx > subsciptionRecivers.length);
        subsciptionStartTime += subscriptionPeriod;
        subsciptionReciverInedx = 0;
        SubsciptionsLocked = false;
    }

    function _incrementSubsciptionPeriod(uint8 times) public {
        require(msg.sender == owner);
        require(SubsciptionsLocked);
        uint256 subsciptionReciverInedxTmp = subsciptionReciverInedx;
        uint256 subscriptionsInedxTmp = subscriptionsInedx;
        require(subsciptionReciverInedxTmp <= subsciptionRecivers.length, 'your done');
        address reciver = subsciptionRecivers[subsciptionReciverInedxTmp];
        for(uint8 i = 0; i<times; i++){
            if(subscriptionsInedxTmp >= subscriptions[reciver].length){
                subscriptionsInedxTmp = 0;
                subsciptionReciverInedxTmp++;
                if(subsciptionReciverInedxTmp > subsciptionRecivers.length){break;}
                reciver = subsciptionRecivers[subsciptionReciverInedxTmp];
            }
            address sender = subscriptions[reciver][subscriptionsInedxTmp];
            if(sender == address(0)){
                subscriptionsInedxTmp++;
                continue;
            }
            if(balanceOf(sender) < subscriptionAmount){//force unsubscribe if user cant afford
                subscriptions[reciver][subscriptionsInedxTmp] = address(0);
            }else{
                _transfer(sender, reciver, subscriptionAmount);
            }
            subscriptionsInedxTmp++;
                continue;
        }  
        subsciptionReciverInedx = subsciptionReciverInedxTmp;
        subscriptionsInedx = subscriptionsInedxTmp;
    }

    function lockForSubsciptionPayments() public {
        require(msg.sender == owner);
        require(block.timestamp > subsciptionStartTime + subscriptionPeriod);
        SubsciptionsLocked = true;
    }
    /*
    function incrementSubsciptionStartTime() public {
        require(msg.sender = owner);
        require(block.timestamp > subsciptionStartTime + subscriptionPeriod);
        subsciptionStartTime += subscriptionPeriod;
        //also need to reset all subsciptionReciversCanClaimPayment
    }

    function resetSubsciptionReciversCanClaimPayment(address reciver, address[] senders) public {
        require(msg.sender = owner);
        for(uint8 i = 0; i < senders.length; i++){
            _resetSubsciptionReciversCanClaimPayment(reciver, senders[i]);
        }
    }

    function _resetSubsciptionReciversCanClaimPayment(address reciver, address sender) internal {
        subsciptionReciversCanClaimPayment[reciver][sender] = 1;
    }

    function addSubsciptionReciver(address reciver) public {
        require(msg.sender = owner);
        subsciptionRecivers.push(reciver);
    }

    function getSubsciptionRecivers() public returns(address[]){
        return subsciptionRecivers;
    }

    function subscribe(address reciver) public {
        transfer(reciver, subscriptionAmount);//pay amount for this subscription period
        subscriptions[reciver].push(msg.sender);
    }

    function claimSubscriptions(address[] senders) internal {
        for(uint8 i = 0; i < senders.length; i++){
            _claimSubscription(senders[i]);
        }
    }

    function _claimSubscription(address sender) internal {
        require(subsciptionReciversCanClaimPayment[msg.sender][sender], 'funds cannot be claimed by this user');
        _transfer(sender, msg.sender, subscriptionAmount);
        subsciptionReciversCanClaimPayment[msg.sender][sender]=0;
    }
    /*

    /*
    function openChannel() public {

    }

    function startCancelChannel() public {
        
    }

    function cancelChannel() public {
        
    }

    function payeeChannel() public {
        
    }

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