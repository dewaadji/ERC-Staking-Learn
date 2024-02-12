// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "@openzeppelin/contracts@5.0.1/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Staking is IERC721Receiver, ERC721Holder {

    IERC721 immutable nft;
    ERC20 immutable token;

    //mapping to save stakes
    mapping (address => mapping(uint256 => uint256)) public stakes;

    constructor(address _nft, address _token) {
        nft = IERC721(_nft);
        token = ERC20(_token);
    }

    function calculateRate(uint256 time) private pure returns(uint256) {
        if(time < 1 minutes) {
            return 0;
        } else if(time < 3 minutes) {
            return 3;
        } else if(time < 5 minutes) {
            return 5;
        } else{
            return 10;
        }
    }

    function staking(uint256 _tokenId) public {
        require(nft.ownerOf(_tokenId) == msg.sender, "You're not own this NFT");
        //stake NFT
        stakes[msg.sender][_tokenId] = block.timestamp;
        nft.safeTransferFrom(msg.sender, address(this), _tokenId, "");
    }

    function calculateReward(uint256 _tokenId) public view returns(uint256) {
        require(stakes[msg.sender][_tokenId] > 0, "You never stake this NFT");
        uint256 time = block.timestamp - stakes[msg.sender][_tokenId];
        uint256 rewardAmount = calculateRate(time) * time * (10 ** 18) / 1 minutes;
        return rewardAmount;
    }

    function unstake(uint256 _tokenId) public {
        //calculate reward
        uint256 rewardAmount = calculateReward(_tokenId);
        delete stakes[msg.sender][_tokenId];
        nft.safeTransferFrom(address(this), msg.sender, _tokenId, "");

        token.transfer(msg.sender, rewardAmount);

        //transfer nft back to original owner
        //send reward
    }

}