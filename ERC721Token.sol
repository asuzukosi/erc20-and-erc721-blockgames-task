// SPDX-License-Identifier: GPL-3.0
// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: learning_zepplin/ERC721Token.sol


pragma solidity ^0.8.0;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

interface ERC721Token {
  /*
    This is the interface for the ERC721 token popularly known as NFTs
  */

  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId); // This is an event to signify that a transaction has occured
  event Approval(address indexed _owner,address indexed _approved,uint256 _tokenId); // This is an event that is triggered when an address is given approval for an nft
  event ApprovalForAll(address indexed _owner,address indexed _operator,bool _approved); // This is an event that is triggered when an address give another operator addreess permission to act on its behalf

  function balanceOf(address _owner) external view returns (uint256 _balance); // This is used to get the balance of a particular address
  function ownerOf(uint256 _tokenId) external view returns (address _owner); // This is a method used to get the owner of a particular token(NFT)
  function exists(uint256 _tokenId) external view returns (bool _exists); // This is a method used to check if a token exists
  
  function name() external view returns (string memory _name); // This returns the name of the ERC721 Token/ the NFT project name
  function symbol() external view returns (string memory _symbol); // This returns the symbol of the ERC721 Token / the NFT project symbol
  function tokenURI(uint256 _tokenId) external view returns (string memory); // This returns the URI of a specified token

  function approve(address _to, uint256 _tokenId) external; // This is used to grant an address approval on a particular token
  function getApproved(uint256 _tokenId) external view returns (address _operator);// This is used to get the address approved for this particular token

  function setApprovalForAll(address _operator, bool _approved) external; // This is used to give an operator approval to perform operations on its behalf
  function isApprovedForAll(address _owner, address _operator) external view returns (bool); // this is used to check if an address has operator access on another address

  function transferFrom(address _from, address _to, uint256 _tokenId) external; // This is used to transfer a token from the owner to another address
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external; // This is used to safely transfer tokens from one address to another

  function safeTransferFrom( address _from, address _to, uint256 _tokenId, bytes memory _data) external; // This is used to safely transfer tokens from one address to another with data
}

contract BoredDoggoYatchClub is ERC721Token {
    // This is used to define the meta data of a bored doggo yatch club doggo
    struct BoredDoggo {
        uint256 tokenId;
        string name;
        string image;
        string description;
    }

    // Mapping from token ID to owner
    mapping (uint256 => address) internal tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) internal tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => uint256) internal ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) internal operatorApprovals;

    // Mapping of tokenIds to BoredDoggo objects
    mapping( uint256 => BoredDoggo) internal boredDoggos;

    // Using counters from open zepplin
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    Counters.Counter private _tokenIdCounter;

    // This is a modifier used to specify that only the owner of a token can call the method
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    // This s a modifier used to specify that only the owner of an account or an account 
    // that has been approved to send that token can call the method
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _;
    }

    string public override  name = "Bored Doggos Yatch Club";
    string public override symbol = "BDYC";  
    bytes private _unimportant_data;

    // Get the owner of a particular token
    function ownerOf(uint256 _tokenId) public override view returns (address) {
      address owner = tokenOwner[_tokenId];
      require(owner != address(0));
      return owner;
    }

    // This is a method used to get the number of tokens owned by a account
    function balanceOf(address _owner) view override public returns(uint256){
      return ownedTokensCount[_owner];
    }
    // This method is used to check if a token exists
    function exists(uint256 _tokenId) public override view returns (bool) {
      address owner = tokenOwner[_tokenId];
      return owner != address(0);
    }
    
    // This is a method to get the address that has been approved to transfer this token
    function getApproved(uint256 _tokenId) public override view returns (address) {
      return tokenApprovals[_tokenId];
    }
 
    // This  is a method used to check if an owner has granted an operator approval to perform actions on their behalf
    function isApprovedForAll(address _owner, address _operator) public override view returns (bool){
      return operatorApprovals[_owner][_operator];
    }

    // This is a method used to approve another address to transfer a specified token
    function approve(address _to, uint256 _tokenId) override public {
      address owner = ownerOf(_tokenId); // get the owner of the token
      require(_to != owner); // the account getting the approval should not be the owner of the token
      require(msg.sender == owner || isApprovedForAll(owner, msg.sender)); // check if hte message sender is the owner or is approved by the owner

      if (getApproved(_tokenId) != address(0) || _to != address(0)) {
        tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId); // Emit that a token approval has occured
      }
    }

    // check if an address has approval  for a particular token or is the owner of hte token
    function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool){
      address owner = ownerOf(_tokenId);
      return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }

    // this is a method used to set approval for a particular address from a message sender
    function setApprovalForAll(address _to, bool _approved) override public {
      require(_to != msg.sender);
      operatorApprovals[msg.sender][_to] = _approved;
      emit ApprovalForAll(msg.sender, _to, _approved);
    }
    
    
    //this method is used to clear current approval of a given token ID
    function clearApproval(address _owner, uint256 _tokenId) internal {
      require(ownerOf(_tokenId) == _owner);
      if (tokenApprovals[_tokenId] != address(0)) {
        tokenApprovals[_tokenId] = address(0);
        emit Approval(_owner, address(0), _tokenId);
      }
    }


    //this is a method to add a token ID to the list of a given address
    function addTokenTo(address _to, uint256 _tokenId) internal {
      require(tokenOwner[_tokenId] == address(0));
      tokenOwner[_tokenId] = _to;
      ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

    //this is an internal method to remove a token ID from the list of a given address
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
      require(ownerOf(_tokenId) == _from);
      ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
      tokenOwner[_tokenId] = address(0);
    }
  
    //this is a method used to transfer ownership of a token from one account to another
    function transferFrom(address _from, address _to, uint256 _tokenId) public override canTransfer(_tokenId){
      require(_from != address(0));
      require(_to != address(0));

      clearApproval(_from, _tokenId);
      removeTokenFrom(_from, _tokenId);
      addTokenTo(_to, _tokenId);

      emit Transfer(_from, _to, _tokenId);
    }

    // this is a method to safely transfer a token from one account to another
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public override canTransfer(_tokenId) {
      transferFrom(_from, _to, _tokenId);

    }
    
    // this is a method to safely transfer a token from one account to another with data
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public override canTransfer(_tokenId) {
      _unimportant_data = _data;
      transferFrom(_from, _to, _tokenId);

    }

    // this is the internal mint method to mint out a new bored doggo nft
    function _mint(address _to, uint256 _tokenId) internal {
      require(_to != address(0));
      addTokenTo(_to, _tokenId);
      emit Transfer(address(0), _to, _tokenId);
    }

    // this is the internal _safeMint method to safely mint out a new bored doggo nft
    function _safeMint(address _to, uint256 _tokenId) internal {
      _mint(_to, _tokenId);

    }


    // safely minting a new bored doggo nft
    function safeMint(address to, string memory _uri, string memory _name, string memory _description) public returns(uint256){
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        BoredDoggo memory _newBoredDoggo = BoredDoggo(tokenId, _name, _uri, _description);
        boredDoggos[tokenId] = _newBoredDoggo;
        return tokenId;
    }

    // this is a method used to burn a token
    function _burn(address _owner, uint256 _tokenId) internal {
      clearApproval(_owner, _tokenId);
      removeTokenFrom(_owner, _tokenId);
      emit Transfer(_owner, address(0), _tokenId);
    }


    function burnToken(uint256 _tokenId) public canTransfer(_tokenId){
      address _owner = ownerOf(_tokenId);
      _burn(_owner, _tokenId);
    }
    // this is used to get the image url of a particular token 
    function tokenURI(uint256 tokenId) public view override returns (string memory){
        BoredDoggo memory _bd = boredDoggos[tokenId];
        return _bd.image; 
    }

    // this is used to get the name url of a particular token 
    function tokenName(uint256 tokenId) public view returns (string memory){
        BoredDoggo memory _bd = boredDoggos[tokenId];
        return _bd.name; 
    }

    // this is used to get the description url of a particular token 
    function tokenDescription(uint256 tokenId) public view returns (string memory){
        BoredDoggo memory _bd = boredDoggos[tokenId];
        return _bd.description; 
    }
}
