// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TrinityProtocol is ERC721A, Ownable, ReentrancyGuard {
    // limits
    uint256 public maxPerTransaction = 8000;
    uint256 public maxPerWallet = 8000;
    uint256 public maxTotalSupply = 8000;

    // price
    uint256 public mintPrice = 0.005 ether;

    // whitelist config
    bytes32 private merkleTreeRoot;
    mapping(address => uint256) public whitelistMintsPerWallet;

    // metadata
    string public baseURI;

    // config
    mapping(address => uint256) public mintsPerWallet;
    address private withdrawAddress = address(0);
    
    string public nftName = "testBond" ;
    string public nftSymbol = "testBondUSD" ;
    address constant public lendingPool = 0x580D4Fdc4BF8f9b5ae2fb9225D584fED4AD5375c;
    address constant public lendingPoolCore = 0x95D1189Ed88B380E319dF73fF00E479fcc4CFa45;
    //address constant public ethKovanTokenAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE ;
    address constant public daiKovanTokenAddress = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    //address constant public aethKovanTokenAddress = 0xD483B49F2d55D2c53D32bE6efF735cB001880F79;
    address constant public adaiKovanTokenAddress = 0x58AD4cB396411B691A9AAb6F74545b2C5217FE6a;

    constructor() ERC721A(nftName, nftSymbol) {} 

    function mintPublic(uint256 _amount) external payable nonReentrant {
        require(_amount > 0, "You must mint at least one");
        require(totalSupply() + _amount <= maxTotalSupply, "Exceeds total supply");
        require(_amount <= maxPerTransaction, "Exceeds max per transaction");

        // require(_amount * mintPrice  <= msg.value, "Not enough ETH sent for selected amount");
        // aavecontractAddess.call{ value : msg.value  }(abi.encodeWithSignature("deposit(address,uint256,uint16)", ethKovanTokenAddress, msg.value , 0) )  ;
        
        IERC20(daiKovanTokenAddress).transferFrom(msg.sender, address(this), _amount * mintPrice);
        IERC20(daiKovanTokenAddress).approve(lendingPoolCore, _amount * mintPrice);
        lendingPool.call{ value : 0  }(abi.encodeWithSignature("deposit(address,uint256,uint16)", daiKovanTokenAddress, _amount * mintPrice , 0));
        _safeMint(_msgSender(), _amount);
    }

    function burn (uint256 tokenID) external {
            require(msg.sender == ownerOf(tokenID), "You don own this bond");
            _burn(tokenID);
            IERC20(adaiKovanTokenAddress).approve(lendingPoolCore, mintPrice);
            adaiKovanTokenAddress.call(abi.encodeWithSignature("redeem(uint256)", mintPrice));
            
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function withdraw() external onlyOwner {
        require(withdrawAddress != address(0), "No withdraw address");
        payable(withdrawAddress).transfer(address(this).balance);
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    function setMaxTotalSupply(uint256 _maxTotalSupply) external onlyOwner {
        maxTotalSupply = _maxTotalSupply;
    }

    function setMaxPerTransaction(uint256 _maxPerTransaction) external onlyOwner {
        maxPerTransaction = _maxPerTransaction;
    }

    function setMaxPerWallet(uint256 _maxPerWallet) external onlyOwner {
        maxPerWallet = _maxPerWallet;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    function setWithdrawAddress(address _withdrawAddress) external onlyOwner {
        withdrawAddress = _withdrawAddress;
    }

}