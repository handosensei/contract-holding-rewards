// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @title Meta-Life: Holding reward
/// @author Hando Masahashi
/// @notice This smart contract is used for reward holders
contract LegendsZoneRewards is ERC1155, Ownable, ReentrancyGuard {

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

    address payable public collector;

    struct TokenReward {
        uint256 id;
        string name;
        uint256 totalSupply;
        bool mintable;
        bool burnable;
        uint256 maxSupply;
        uint256 expireAt;
    }

    struct Eligibility {
        uint256 total;
        uint256 claimed;
    }

    mapping(address => mapping(uint256 => Eligibility)) public holderEligibilities;
    mapping(uint256 => TokenReward) public tokenCollection;

    event AddedEligibility(uint256 countAddresses, uint256 total);
    event Minted(address indexed from, uint256 timestamp, uint256 tokenId, uint256 quantity);
    event Burned(address indexed from, uint256 timestamp, uint256 tokenId, uint256 quantity);

    constructor() ERC1155("") {
        collector = payable(msg.sender);
        // expire at 2024 06 30
        uint256 expireAt = 1719784799;
        addToken("cyber-weapon", true, false, 15000, ID_CYBER_WEAPON, expireAt);
        addToken("cyber-armor", false, false, 15000, ID_CYBER_ARMOR, expireAt);
        addToken("rough-pet", false, false, 15000, ID_ROUGH_PET, expireAt);
        addToken("roboter-weapon",  false, false, 15000, ID_ROBOTER_WEAPON, expireAt);
        addToken("matrix-angel-car", false, false, 15000, ID_MATRIX_ANGEL_CAR, expireAt);
        addToken("ml-network-pass", false, false, 12000, ID_ML_NETWORK_PASS, expireAt);
        addToken("particle-cosmetic-effect", false, false, 12000, ID_PARTICLE_COSMETIC_EFFECT, expireAt);
        addToken("shadow-gem", false, false, 8000, ID_SHADOW_GEM, expireAt);
    }

    function withdrawAll() public payable onlyOwner {
        collector.transfer(address(this).balance);
    }

    function setCollector(address payable _newCollector) public onlyOwner {
        collector = _newCollector;
    }

    function toggleTokenMint(uint256 _tokenId) public onlyOwner {
        tokenCollection[_tokenId].mintable = !tokenCollection[_tokenId].mintable;
    }

    function toggleTokenBurnable(uint256 _tokenId) public onlyOwner {
        tokenCollection[_tokenId].burnable = !tokenCollection[_tokenId].burnable;
    }

    function getTokenRewardStatus(uint256 _tokenId) public view returns (bool) {
        return tokenCollection[_tokenId].mintable;
    }

    function isBurnable(uint256 _tokenId) public view returns (bool) {
        return tokenCollection[_tokenId].burnable;
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

    function addToken(string memory _name, bool _mintable, bool _burnable, uint256 _maxSupply, uint256 _id, uint256 _expireAt) public onlyOwner {
        tokenCollection[_id] = TokenReward({
            id: _id,
            name: _name,
            totalSupply: 0,
            mintable: _mintable,
            burnable: _burnable,
            maxSupply: _maxSupply,
            expireAt: _expireAt
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
        require(block.timestamp < tokenCollection[_tokenId].expireAt, "Holding reward mint close");
        holderEligibilities[msg.sender][_tokenId].claimed += _quantity;
        tokenCollection[_tokenId].totalSupply += _quantity;
        _mint(msg.sender, _tokenId, _quantity, "");

        emit Minted(msg.sender, block.timestamp, _tokenId, _quantity);
    }

    function burn(uint256 _tokenId, uint256 _quantity) external {
        require(tokenCollection[_tokenId].burnable, "Cant burn token");
        require(balanceOf(msg.sender, _tokenId) >= _quantity, "Not enought token to burn");

        _burn(msg.sender, _tokenId, _quantity);

        emit Burned(msg.sender, block.timestamp, _tokenId, _quantity);
    }
}
