pragma solidity ^0.6.0;

import "./openzeppelin/math/SafeMath.sol";
import "./IOracle.sol";
import "./openzeppelin/access/Ownable.sol";

contract MOracle is Oracle,Ownable {
  mapping(address => uint) public override liquidityValues;
  uint public override syncValue=0;
  constructor() public Ownable(){

  }
  function setValue(address t,uint val) public onlyOwner{
    liquidityValues[t]=val;
  }
  function setSyncValue(uint value) public onlyOwner{
    syncValue=value;
  }
}
