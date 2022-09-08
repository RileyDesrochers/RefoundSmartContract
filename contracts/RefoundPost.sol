// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
//import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
// We need to import the helper functions from the contract that we copy/pasted.

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract RefoundPost is ERC721URIStorage {
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    //using Counters for Counters.Counter;
    //Counters.Counter private _tokenIds;
    uint256 public posts;
    address public refound;

    // We need to pass the name of our NFTs token and its symbol.
    constructor(address _refound) ERC721 ("RefoundPost", "FND") {
        refound = _refound;
        posts = 0;
    }

    // A function our user will hit to get their NFT.
    function makeRefoundPost(uint256 profileID, string memory postData) public returns(uint256){

        require(msg.sender == refound, "handle to long");//fix this and turn into modifier
        // Get the current tokenId, this starts at 0.
        uint256 postID = posts++;
        
        string memory tokenURI = string(
            abi.encodePacked(
                '{"Handle": ',
                handle,
                ', "ProfileData": ',
                profileData,
                '}'
            )
        );
        
        _safeMint(msg.sender, postID);

        // Set the NFTs data.
        _setTokenURI(profileID, tokenURI);
        console.log("minted post NFT", postID, msg.sender, tokenURI);
        return profileID;
    }
}