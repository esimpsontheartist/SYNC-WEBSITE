pragma solidity ^0.6.0;


import "./IERC20.sol";
import "./openzeppelin/math/SafeMath.sol";
import "./openzeppelin/access/Ownable.sol";
import "./ApproveAndCallFallback.sol";

contract Sync is ERC20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;
  mapping (address => mapping (address => uint256)) private allowed;
  string public constant name  = "Sync";
  string public constant symbol = "SYNC";
  uint8 public constant decimals = 18;
  uint256 _totalSupply = 15000000 * (10 ** 18); // 15 million supply

  mapping (address => bool) private mintContracts;

  modifier isMintContract() {
    require(mintContracts[msg.sender],"calling address is not allowed to mint");
    _;
  }

  constructor() public Ownable(){
    balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function setMintAccess(address account, bool canMint) public onlyOwner {
    mintContracts[account]=canMint;
  }

  function _mint(address account, uint256 amount) public isMintContract {
    require(account != address(0), "ERC20: mint to the zero address");
    _totalSupply = _totalSupply.add(amount);
    balances[account] = balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function totalSupply() public view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address user) public view override returns (uint256) {
    return balances[user];
  }

  function allowance(address user, address spender) public view override returns (uint256) {
    return allowed[user][spender];
  }

  function transfer(address to, uint256 value) public override returns (bool) {
    require(value <= balances[msg.sender]);
    require(to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[to] = balances[to].add(value);

    emit Transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public override returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function approveAndCall(address spender, uint256 tokens, bytes calldata data) external override returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

  function transferFrom(address from, address to, uint256 value) public override returns (bool) {
    require(value <= balances[from]);
    require(value <= allowed[from][msg.sender]);
    require(to != address(0));

    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);

    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, value);
    return true;
  }

  function burn(uint256 amount) override external {
    require(amount != 0);
    require(amount <= balances[msg.sender]);
    _totalSupply = _totalSupply.sub(amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    emit Transfer(msg.sender, address(0), amount);
  }

}
