// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Holding rewards
/// @author Hando Masahashi
/// @notice This smart contract is used for reward holders
contract HoldingReward is ERC1155, Ownable, ReentrancyGuard {

    using Strings for uint256;
    string public baseURI = "";
    uint256 public currentToken = 0;

    struct TokenReward {
        uint256 id;
        string name;
        uint256 totalSupply;
        uint256 mintable;
    }

    mapping(uint256 => TokenReward) public tokenCollection;

    constructor() ERC1155("") {
    }

    function _setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function _baseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 _tokenId) public view virtual returns (string memory) {
        string memory uri = _baseURI();
        return bytes(uri).length > 0 ? string(abi.encodePacked(uri, _tokenId.toString())) : "";
    }

    function addToken(string memory _name, bool _mintable) public onlyOwner {
        currentToken++;
        tokenCollection[currentToken] = TokenReward({
            id: currentToken,
            name: _tokenName,
            totalSupply: 0,
            mintable: _mintable
        });
    }

    function toggleTokenMint(uint256 _id) public onlyOwner {
        tokenCollection[_id].mintable = !tokenCollection[_id].mintable;
    }

    function getTokenRewardStatus(uint256 _id) public view returns (bool) {
        return tokenCollection[_id].mintable;
    }
}
