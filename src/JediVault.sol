// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract JediToken {
    string public constant NAME = "Jedi Token";
    string public constant SYMBOL = "JEDI";
    uint8 public immutable i_decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor (uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint256(i_decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address recipient, uint256 amount) public returns (bool success) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance.");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool success) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool success) {
        require(balanceOf[sender] >= amount, "Insufficient balance.");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded.");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address (0), "ERC20: burn from the zero address");
        require(balanceOf[account] >= amount, "Burn amount exceeds balance");
        balanceOf[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
}

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool success);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool success);
}



contract JediVault is JediToken{
    IERC20 public immutable token;

    constructor(address _tokenAddress) JediToken(0) {
        token = IERC20(_tokenAddress);
    }

    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        require(token.transfer(msg.sender, amount), "Transfer failed");
    }

}