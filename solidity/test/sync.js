const DeployAll = artifacts.require("DeployAll");
const Sync = artifacts.require("Sync");
const FRS = artifacts.require("FRS")
const ez="000000000000000000"
const eznum=1000000000000000000
contract("DeployAll", accounts => {
  it("...should create the contracts with correct amounts.", async () => {
    const accountOne = accounts[0];
    const accountTwo = accounts[1];
    const accountThree = accounts[2];

    const deployInstance = await DeployAll.deployed();
    const frsAddr= await deployInstance.f.call();
    const tokenAddr = await deployInstance.s.call();
    const token=await Sync.at(tokenAddr)

    accountOneStartBalance=(await token.balanceOf.call(accountOne)).valueOf()
    console.log(accountOneStartBalance,parseFloat(accountOneStartBalance))
    assert.equal(10000000*eznum,parseFloat(accountOneStartBalance),"should start with 10mil")
    const amount1 = 100000;
    const amount2 = 50000;
    await token.transfer(accountTwo, amount1+ez, { from: accountOne });
    const accountOneEndingBalance = parseFloat((await token.balanceOf.call(accountOne)).valueOf())///eznum;
    const accountTwoStartBalance = parseFloat((await token.balanceOf.call(accountTwo)).valueOf())///eznum;
    console.log('balance 2 is ',parseFloat((await token.balanceOf.call(accountTwo)).valueOf()))
    assert.equal(accountTwoStartBalance , amount1*eznum,"account 2 should have received the full amount")
  });

});
