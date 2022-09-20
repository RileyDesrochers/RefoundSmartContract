// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//import "./ERC2981.sol";
//import "./IERC2981.sol";
//import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
// We need to import the helper functions from the contract that we copy/pasted.

enum LicenseType{Outright, WebLicense, PrintLicense, SingleUse}
enum contentInteraction{None, UpVote, DownEote, Report}

struct License{
    //string owner;
    uint256 postID;
    LicenseType Ltype;
}

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract RefoundPost is ERC721URIStorage, ERC2981, Ownable {
    IERC20 currency;

    mapping(uint256 => mapping(address => contentInteraction)) contentInteractions; //tokenID, interactorAddress to contentInteraction
    mapping(uint8 => uint256) prices;

    //address public owner;
    uint256 public posts;
    address public refound;
    mapping(address => License[]) buyerAddresstoLicense;

    // We need to pass the name of our NFTs token and its symbol.
    constructor(address _refound, address _currency) ERC721 ("RefoundPost", "FOUNDP") {
        //owner == msg.sender;
        refound = _refound;
        posts = 0;
        //console.log('owner: ', msg.sender);
        currency = IERC20(_currency);
    }

    function updatePrice(uint8 index, uint256 price) public onlyOwner() {//FIX needs modifer 
        //require(msg.sender == owner, 'only owner');//FIX make modifer
        //console.log('address of caller: ', msg.sender);
        prices[index] = price;
    }

   //contentInteractionAddresses[postID]
   function getContentInteractions(uint256 postID, address user) public view returns(contentInteraction) {
        return contentInteractions[postID][user];
    }

    function getLicensesByAddress(address user) public view returns(License[] memory) {
        return buyerAddresstoLicense[user];
    }

    // A function our user will hit to get their NFT.
    function makeRefoundPost(uint256 profileID, string memory postData, address postOwner/*, uint8 LicenseType*/) external returns(uint256){
        require(msg.sender == refound, "only the refound contract can make a post");//FIX this and turn into modifier

        // Get the current tokenId, this starts at 0.
        uint256 postID = posts++;
        
        postIDtoOwner[postOwner].push(postID);//for testing only 

        string memory tokenURI = string(
            abi.encodePacked(
                '{"posterID": ',
                Strings.toString(profileID),
                ', "postData": ',
                postData,
                '}'
            )
        );
        
        _safeMint(postOwner, postID);

        // Set the NFTs data.
        _setTokenURI(postID, tokenURI);
        console.log("minted post NFT", postID, postOwner, tokenURI);
        return postID;
    }

    function interactWithContent(uint256 postID, uint8 interactionType) public {
        require(interactionType != 0);
        if(contentInteractions[postID][msg.sender] != contentInteraction(0)){
            contentInteractionAddresses[postID].push(msg.sender);
        }
        contentInteractions[postID][msg.sender] = contentInteraction(interactionType);
    }

    function purchaseLicense(/*string memory _owner, */ uint256 postID, uint8 licenseType) public {
        currency.transferFrom(msg.sender, ownerOf(postID), prices[licenseType]);
        buyerAddresstoLicense[msg.sender].push(License(/*_owner, */postID, LicenseType(licenseType)));
    }

    //-------------------------------------------------------------------------------------

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    //using Counters for Counters.Counter;
    //Counters.Counter private _tokenIds;

    mapping(address => uint256[]) postIDtoOwner;//for testing only
    mapping(uint256 => address[]) contentInteractionAddresses;//for testing only

    function getPostIDs(address user) public view returns(uint256[] memory) {//for testing only
        return postIDtoOwner[user];
    }

    function getContentInteractionAddresses(uint256 postID) public view returns(address[] memory) {//for testing only
        return contentInteractionAddresses[postID];
    }

}