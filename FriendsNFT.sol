pragma solidity ^0.8.0;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/ERC721.sol";
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/utils/math/SafeMath.sol";

contract FriendsNFT is ERC721URIStorage {
    using SafeMath for uint256;
    
    address internal contractOwner;
    uint256 internal tokenIDCount = 0;
    
    bytes32 constant emptyString = 0x569e75fc77c1a856f6daaf9e69d8a9566ca34aa47f9133711ce065a571af0cfd;
    
    mapping (string => string) internal tokenURLMap; 
    
    constructor() ERC721 ("FriendsNFT", "FRIENDSNFT") {
        contractOwner = msg.sender;
    }
    
    modifier onlyOwner {
        require (contractOwner == msg.sender, "Error: Not Contract Owner");
        _;
    }
    
    modifier contractOwnsNFT (uint256 _tokenID) {
        require(this.ownerOf(_tokenID) == address(this), "Error: Contract does not own NFT");
        _;
    }
    
    function getNextTokenID() internal returns (uint256) {
        tokenIDCount++;
        
        return tokenIDCount;
    }
    
    function isEmptyString(string memory _string) internal pure returns (bool) {
        bytes32 _bytesStrings = keccak256(abi.encode(_string));
        
        return (_bytesStrings == emptyString);
    }
    
    function changeOwner (address _newOwner) public onlyOwner {
        contractOwner = _newOwner;
    }
    
    function setNFTTokenURI (string memory _NFTName, string memory _NFTTokenURI) public onlyOwner {
        if (isEmptyString(_NFTTokenURI)){
            delete tokenURLMap[_NFTName];
        } else {
          tokenURLMap[_NFTName] = _NFTTokenURI;  
        }
    } 
    
    function mintNFT(string memory _NFTName) public onlyOwner returns (uint256) {
        uint256 _tokenID = getNextTokenID();
        string memory _thisNFTURI = tokenURLMap[_NFTName];
        
        require(!isEmptyString(_thisNFTURI), "Error: No NFT URI defined");
        
        _mint(address(this), _tokenID);
        _setTokenURI(_tokenID, _thisNFTURI);
        
        return _tokenID;   
    }
    
    function sendNFTFromContract (address _to, uint256 _tokenID) public onlyOwner contractOwnsNFT(_tokenID) {
        this.transferFrom(address(this), _to, _tokenID);
    }
    
    function getNFTURI (string memory _NFTName) public view returns(string memory) {
        return tokenURLMap[_NFTName];
    }
    
    // function test() public view returns (bytes32) {
    //     string memory p = tokenURLMap["Hello"];
    //     return keccak256(abi.encode(p));
    // }
}