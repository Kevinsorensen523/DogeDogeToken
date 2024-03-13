// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IDogeDogeToken {
    function buyToken() external payable;
    function transferToken(address to, uint value) external;
    function blockTransfer(address target) external;
    function unblockTransfer(address target) external;
    function retrieveIncome(uint value) external payable;
    function getProgrammerName() external pure returns (string memory);
    function getUserToken(address user) external view returns (uint);
    function calculateTokenCost(uint value) external pure returns (uint);
    function isUserBlocked(address from, address to) external view returns (bool);

    event TokenPurchased(address indexed buyer, uint value);
    event TokenTransferred(address indexed from, address indexed to, uint value);
}

contract DogeDogeToken {
    address public owner;
    uint public stock;

    mapping(address => uint) public balances;

    mapping(address => bool) public blockedAddresses;

    event TokenPurchased(address indexed buyer, uint value);

    event TokenTransferred(address indexed from, address indexed to, uint value);
    
    receive() external payable {}

    constructor(address _owner, uint _stock) {
        owner = _owner;
        stock = _stock;
    }

    // Ya functionnya jalan tapi valuenya 0 terus
    function buyToken() public payable  {
        require(msg.sender != owner, "Owner tidak dapat menggunakan fungsi ini");
        require(msg.value % 100 == 0, "Jumlah pembelian harus kelipatan 100 gwei");

        uint tokensToBuy = msg.value / 100;
        require(tokensToBuy <= stock, "Stok token tidak mencukupi");

        balances[msg.sender] += tokensToBuy;
        stock -= tokensToBuy;

        emit TokenPurchased(msg.sender, tokensToBuy);
        
    }

    function transferToken(address to, uint value) public  {
        require(msg.sender != to, "Tidak dapat mentransfer ke diri sendiri");
        require(value <= balances[msg.sender], "Saldo token tidak mencukupi");
        require(!blockedAddresses[to], "Alamat tujuan diblokir");

        balances[msg.sender] -= value;
        balances[to] += value;

        emit TokenTransferred(msg.sender, to, value);
    }

    function blockTransfer(address target) public {
        require(msg.sender == owner, "Hanya owner yang dapat memblokir address");
        blockedAddresses[target] = true;
    }

    function unblockTransfer(address target) public {
        require(msg.sender == owner, "Hanya owner yang dapat membuka blokir address");
        blockedAddresses[target] = false;
    }

    function retrieveIncome(uint value) public payable{
        require(msg.sender == owner, "Hanya owner yang dapat mengambil profit");
        require(value <= address(this).balance, "Profit tidak mencukupi");

        payable(owner).transfer(value);
    }

    function getProgrammerName() public pure returns (string memory) {
        return "KevinSorensen";
    }

    function getUserToken(address user) public view returns (uint) {
        return balances[user];
    }

    function calculateTokenCost(uint value) public pure returns (uint) {
        require(value % 100 == 0, "Jumlah pembelian harus kelipatan 100 gwei");
        return value / 100;
    }

    function isUserBlocked(address from, address to) public view returns (bool) {
        return blockedAddresses[from] && blockedAddresses[to];
    }
}