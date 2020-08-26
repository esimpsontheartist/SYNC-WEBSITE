pragma solidity ^0.6.0;


import "./openzeppelin/token/ERC721/ERC721.sol";
import "./openzeppelin/math/SafeMath.sol";
import "./openzeppelin/access/Ownable.sol";
import "./opensea/Strings2.sol";

contract CBOND is ERC721, Ownable {
  using SafeMath for uint256;

  constructor() public Ownable() ERC721("CBOND","CBOND"){

  }
  function setBaseURI(string memory baseURI_) public onlyOwner{
    _setBaseURI(baseURI_);
  }
}
