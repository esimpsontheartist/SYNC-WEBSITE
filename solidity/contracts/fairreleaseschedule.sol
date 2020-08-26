pragma solidity ^0.6.0;


import "./IERC20.sol";
import "./openzeppelin/math/SafeMath.sol";
import "./Sync.sol";
import "./openzeppelin/access/Ownable.sol";

contract FRS is Ownable {
  using SafeMath for uint;

  uint public startingRewardPerDay = 1000 ether; //amount rewarded per day
  mapping(uint => mapping(address => uint)) public amountEntered; //amount entered by day by user
  mapping(uint => uint) public totalDailyContribution; //the total amount of Eth entered for the given day
  mapping(uint => uint) public totalDailyRewards; //the total amount of tokens to be distributed for the given day
  mapping(uint => mapping(address => uint)) public totalDailyPayouts; //the amount paid out to users per day
  uint public outstandingDebt;
  uint public currentDay=0;
  uint public TIME_INCREMENT=1 hours;//1 days;
  uint public nextDayAt=0;//=now+TIME_INCREMENT;
  uint public firstEntryTime=0;
  Sync public syncToken;

  constructor(address token) public Ownable(){//(address tokenAddr,address fundAddr) public{
    syncToken=Sync(token);
    //restore these later, this just for testing
    //rewardToken=ERC20(tokenAddr);
    //fundDestination=fundAddr;
    totalDailyRewards[currentDay]=startingRewardPerDay;
  }

  function withdrawFunds() public onlyOwner returns(uint){
    uint toTransfer=address(this).balance;
    msg.sender.transfer(toTransfer);
    return toTransfer;
  }

  function enter() public payable{
    updateDay();
    amountEntered[currentDay][msg.sender]+=msg.value;
    totalDailyContribution[currentDay]+=msg.value;
  }
  function updateDay() public{
    //starts timer if first transaction
    if(nextDayAt==0){
      nextDayAt=now.add(TIME_INCREMENT);
      firstEntryTime=now;
    }
    if(now>=nextDayAt){
      outstandingDebt+=totalDailyRewards[currentDay];
      uint daysToAdd=1+(now-nextDayAt)/TIME_INCREMENT;
      nextDayAt+=TIME_INCREMENT*daysToAdd;
      currentDay+=1;
      //for every month until the 13th, rewards are cut in half.
      uint numMonths=now.sub(firstEntryTime).div(31 days);
      if(numMonths>12){
        totalDailyRewards[currentDay]=0;
      }
      else{
        totalDailyRewards[currentDay]=startingRewardPerDay.div(2**numMonths);
      }
    }
  }
  function withdrawForMultipleDays(uint[] memory dayList) public{
    updateDay();
    uint cumulativeAmountWon=0;
    uint amountWon=0;
    for(uint i=0;i<dayList.length;i++){
      amountWon=_withdrawForDay(dayList[i],currentDay,msg.sender);
      cumulativeAmountWon+=amountWon;
      totalDailyPayouts[dayList[i]][msg.sender]+=amountWon;//record how much was paid
    }
    syncToken._mint(msg.sender,cumulativeAmountWon);
    outstandingDebt-=cumulativeAmountWon;
  }
  function withdrawForDay(uint day) public{
    updateDay();
    uint amountWon=_withdrawForDay(day,currentDay,msg.sender);
    totalDailyPayouts[day][msg.sender]+=amountWon;//record how much was paid
    syncToken._mint(msg.sender,amountWon);
    outstandingDebt=outstandingDebt.sub(amountWon);
  }
  /*
    returns amount that should be withdrawn for the given day
  */
  function _withdrawForDay(uint day,uint dayCursor,address user) public view returns(uint){
    if(day>=dayCursor){//you can only withdraw funds for previous days
      return 0;
    }
    uint amountWon=totalDailyRewards[day]*amountEntered[day][user]/totalDailyContribution[day];
    uint amountPaid=totalDailyPayouts[day][user];
    return amountWon.sub(amountPaid);
  }
  /*
    only used externally, intended to assist with frontend calculations, not meant to be called onchain.
  */
  function currentDayActual() external view returns(uint){
    if(now>=nextDayAt){
      return currentDay+1;
    }
    else{
      return currentDay;
    }
  }
  function getPayoutForMultipleDays(uint[] memory dayList,uint dayCursor,address addr) public view returns(uint){
    uint cumulativeAmountWon=0;
    for(uint i=0;i<dayList.length;i++){
      cumulativeAmountWon+=_withdrawForDay(dayList[i],dayCursor,addr);
    }
    return cumulativeAmountWon;
  }
  function getDaysWithFunds(uint start,uint end,address user) external view returns(uint[] memory){
    uint numDays=0;
    for(uint i=start;i<min(currentDay+1,end);i++){
      if(amountEntered[i][user]>0){
        numDays+=1;
      }
    }
    uint[] memory dwf=new uint[](numDays);
    uint cursor=0;
    for(uint i=start;i<min(currentDay+1,end);i++){
      if(amountEntered[i][user]>0){
        dwf[cursor]=i;
        cursor+=1;
      }
    }
    return dwf;
  }
  /*
    utility functions
  */
  function min(uint n1,uint n2) internal pure returns(uint){
    if(n1<n2){
      return n1;
    }
    else{
      return n2;
    }
  }
}
