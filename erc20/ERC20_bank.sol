// SPDX-License-Identifier: MIT
//A simple bank where customer will be enrolled and can deposit and withdraw ERC20 token

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/utils/Address.sol";

import "./ERC20.sol";

pragma solidity ^0.6.4;

contract SimpleBank {
    using SafeMath for uint256;
    using Address for address;

    Token tokenContract;

    mapping(address => uint256) private balances;
    mapping(address => bool) enrolled;

    //create address owner to store contracts owner address
    address public owner;

    modifier OnlyOwner {
        require(owner == msg.sender, "only owner can execute this contract");
        _;
    }

    modifier isEnrolled {
        require(enrolled[msg.sender], "you should be enrolled to deposit");
        _;
    }

    constructor(Token _tokenContract) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
    }

    function getTokenName() public view returns (string memory) {
        return tokenContract.name();
    }

    receive() external payable {
        balances[owner] += msg.value;
    }

    function getBalance() public view returns (uint256) {
        /* Get the balance of the sender of this transaction */
        return balances[msg.sender];
    }

    function enroll(address _account) public OnlyOwner returns (bool) {
        enrolled[_account] = true;
        return enrolled[_account];
    }

    function deposit(uint256 amount) public isEnrolled returns (uint256) {
        // approve the SimpleBank contract with amount
        require(amount != 0, "deposit amount cannot be zero");
        require(tokenContract.transferFrom(msg.sender, address(this), amount));
        balances[msg.sender] = balances[msg.sender].add(amount);
        return balances[msg.sender];
    }

    function withdraw(uint256 withdrawAmount)
        public
        isEnrolled
        returns (uint256)
    {
        require(
            withdrawAmount <= balances[msg.sender],
            "not enough balance in your account"
        );

        balances[msg.sender] = balances[msg.sender].sub(withdrawAmount);
        tokenContract.transfer(msg.sender, withdrawAmount);
        return balances[msg.sender];
    }

    function getContracttBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function checkAddress(address _account) public view returns (bool) {
        return _account.isContract();
    }
}
