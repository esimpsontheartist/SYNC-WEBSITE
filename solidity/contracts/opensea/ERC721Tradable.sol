pragma solidity ^0.6.0;

import '../openzeppelin/token/ERC721/ERC721.sol';
import '../openzeppelin/access/Ownable.sol';
import './Strings2.sol';

contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title ERC721Tradable
 * ERC721Tradable - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
contract ERC721Tradable is ERC721, Ownable {
  using Strings2 for string;

  address proxyRegistryAddress;
  uint256 private _currentTokenId = 0;

  constructor(string memory _name, string memory _symbol, address _proxyRegistryAddress) ERC721(_name, _symbol) Ownable() public {
    proxyRegistryAddress = _proxyRegistryAddress;
  }

  /**
    * @dev Mints a token to an address with a tokenURI.
    * @param _to address of the future owner of the token
    */
  function mintTo(address _to) public onlyOwner {
    uint256 newTokenId = _getNextTokenId();
    _mint(_to, newTokenId);
    _incrementTokenId();
  }

  /**
    * @dev calculates the next token ID based on value of _currentTokenId
    * @return uint256 for the next token ID
    */
  function _getNextTokenId() private view returns (uint256) {
    return _currentTokenId.add(1);
  }

  /**
    * @dev increments the value of _currentTokenId
    */
  function _incrementTokenId() private  {
    _currentTokenId++;
  }

  function baseTokenURI() public view returns (string memory) {
    return "";
  }

  function tokenURI(uint256 _tokenId) external view returns (string memory) {
    return Strings2.strConcat(
        baseTokenURI(),
        Strings2.uint2str(_tokenId)
    );
  }

  /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
   */
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
    // Whitelist OpenSea proxy contract for easy trading.
    ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
    if (address(proxyRegistry.proxies(owner)) == operator) {
        return true;
    }

    return super.isApprovedForAll(owner, operator);
  }
}
