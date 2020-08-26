pragma solidity ^0.6.0;


import "./IERC20.sol";
import "./openzeppelin/math/SafeMath.sol";
import "./Sync.sol";
import "./fairreleaseschedule.sol";

contract DeployAll {
  Sync public s;
  FRS public f;
  constructor() public{
    s=new Sync();
    f=new FRS(address(s));
    s.transfer(msg.sender,s.balanceOf(address(this)));
    s.transferOwnership(msg.sender);
    f.transferOwnership(msg.sender);
  }
}
