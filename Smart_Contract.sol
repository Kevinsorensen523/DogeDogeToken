// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

interface IDogeDogeToken {
    function buyToken() external payable;
    function transferToken(address who, int amount) external;
    function blockTransfer(address who) external;
    function unblockTransfer(address who) external;
    function retrieveIncome() external payable;

    function getUserToken(address from) view external returns (int);
    function calculateTokenCost(int val) external pure returns (int);
    function isUserBlocked(address from, address to) external view returns (bool);
    function getProgrammerName() pure external returns (string memory);
}

contract DogeDogeToken is IDogeDogeToken {

    address owner;
    int stock;
    mapping(address => int) address_token;
    mapping(address => address[]) block_list;
    address[] list_final_temp;

    constructor (address _owner, int _stock) {
        owner = _owner;
        stock = _stock;
    }

    function buyToken() public payable {
        require(msg.sender != owner);
        require(msg.value >= 100 gwei);
        int _val = int(msg.value);

        if (_val % 100 gwei != 0) revert("Value must be multiples of 100 gwei");

        int calc_res = _val / 100 gwei;
        require(calc_res <= stock);

        address_token[msg.sender] += calc_res;
        stock -= calc_res;
    }

    function transferToken(address who, int amount) public {
        require(address_token[msg.sender] > amount);
        if (isUserBlocked(who, msg.sender)) revert("Address blocked!");

        address_token[who] += amount;
        address_token[msg.sender] -= amount;
    }

    function blockTransfer(address who) public {
        require(who != msg.sender);

        block_list[msg.sender].push(who);
    }
    
    function unblockTransfer(address who) public {
        require(who != msg.sender);

        delete list_final_temp;

        for (uint i=0; i<block_list[msg.sender].length; ++i) {
            if (block_list[msg.sender][i] != who) {
                list_final_temp.push(block_list[msg.sender][i]);
            }
        }

        block_list[msg.sender] = list_final_temp;
    }

    function getContractBalance() internal view returns(uint) {
        return address(this).balance;
    }
    function retrieveIncome() public payable {
        require(msg.sender == owner);
        payable(owner).transfer(getContractBalance());
    }

    function getProgrammerName() pure public returns (string memory) {
        return "AlfredKuhlman";
    }

    function getUserToken(address from) view public returns (int) {
        return address_token[from];
    }

    function calculateTokenCost(int val) public pure returns (int) {
        if (val % 100 != 0) revert();
        return val / 100;
    }

    function isUserBlocked(address from, address to) public view returns (bool) {
        bool isBlocked = false;

        for (uint i; i<block_list[from].length; ++i) {
            if (block_list[from][i] == to) {
                isBlocked = true;
            }
        }

        return isBlocked;
    }

}