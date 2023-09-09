// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Meta-Life: Holding reward
/// @author Hando Masahashi
/// @notice This smart contract is used for reward holders
contract MetaLifeHoldingReward is ERC1155, Ownable, ReentrancyGuard {

    using Strings for uint256;
    string public baseURI = "";

    uint256 public constant ID_CYBER_WEAPON = 1;
    uint256 public constant ID_CYBER_ARMOR = 2;
    uint256 public constant ID_ROUGH_PET = 3;
    uint256 public constant ID_ROBOTER_WEAPON = 4;
    uint256 public constant ID_MATRIX_ANGEL_CAR = 5;
    uint256 public constant ID_ML_NETWORK_PASS = 6;
    uint256 public constant ID_PARTICLE_COSMETIC_EFFECT = 7;
    uint256 public constant ID_SHADOW_GEM = 8;

    struct TokenReward {
        uint256 id;
        string name;
        uint256 totalSupply;
        bool mintable;
        uint256 maxSupply;
    }

    struct Eligibility {
        uint256 total;
        uint256 claimed;
    }

    uint256 public limitMintSpecific = 0;
    mapping(address => mapping(uint256 => Eligibility)) public holderEligibilities;
    mapping(uint256 => TokenReward) public tokenCollection;

    event Minted(address indexed from, uint256 timestamp, uint256 tokenId, uint256 quantity);
    event AddedEligibility(uint256 countAddresses, uint256 total);

    constructor() ERC1155("") {
        addToken("cyber-weapon", true, 15000, ID_CYBER_WEAPON);
        addToken("cyber-armor", false, 15000, ID_CYBER_ARMOR);
        addToken("rough-pet", false, 15000, ID_ROUGH_PET);
        addToken("roboter-weapon",  false, 15000, ID_ROBOTER_WEAPON);
        addToken("matrix-angel-car", false, 15000, ID_MATRIX_ANGEL_CAR);
        addToken("ml-network-pass", false, 12000, ID_ML_NETWORK_PASS);
        addToken("particle-cosmetic-effect", false, 12000, ID_PARTICLE_COSMETIC_EFFECT);
        addToken("shadow-gem", false, 8000, ID_SHADOW_GEM);

        limitMintSpecific = block.timestamp + ((365/2) * 24 * 60 * 60);
    }

    function toggleTokenMint(uint256 _id) public onlyOwner {
        tokenCollection[_id].mintable = !tokenCollection[_id].mintable;
    }

    function getTokenRewardStatus(uint256 _id) public view returns (bool) {
        return tokenCollection[_id].mintable;
    }

    function remaining(address wallet, uint256 _tokenId) public view virtual returns (uint256) {
        return holderEligibilities[wallet][_tokenId].total - holderEligibilities[wallet][_tokenId].claimed;
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

    function addToken(string memory _name, bool _mintable, uint256 _maxSupply, uint256 _id) public onlyOwner {
        tokenCollection[_id] = TokenReward({
            id: _id,
            name: _name,
            totalSupply: 0,
            mintable: _mintable,
            maxSupply: _maxSupply
        });
    }

    function addEligilities(address[] calldata _toAddAddresses, uint256[] calldata _quantities, uint256 _tokenId)  external onlyOwner {
        require(_toAddAddresses.length == _quantities.length, "Nb address and nb quantities must be equal");

        uint256 total = 0;
        for (uint256 i = 0; i < _toAddAddresses.length; i++) {
            holderEligibilities[_toAddAddresses[i]][_tokenId].total = _quantities[i];
            total += _quantities[i];
        }

        emit AddedEligibility(_toAddAddresses.length, total);
    }

    function mint(uint256 _tokenId, uint256 _quantity) external {
        require(remaining(msg.sender, _tokenId) >= _quantity, "Quantity greater than remaining");
        require(tokenCollection[_tokenId].mintable, "Token reward close");
        require(tokenCollection[_tokenId].totalSupply + _quantity <= tokenCollection[_tokenId].maxSupply, "Not enough supply");
        require(block.timestamp < limitMintSpecific, "Holding reward mint close");
        holderEligibilities[msg.sender][_tokenId].claimed += _quantity;
        tokenCollection[_tokenId].totalSupply += _quantity;
        _mint(msg.sender, _tokenId, _quantity, "");

        emit Minted(msg.sender, block.timestamp, _tokenId, _quantity);
    }
}
