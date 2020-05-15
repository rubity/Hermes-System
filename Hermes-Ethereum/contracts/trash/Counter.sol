pragma solidity  ^0.6.6;

contract Counter{
    uint count = 0;
    address owner;
    
    constructor () public{
        owner = msg.sender;
    }
    
    function increment() public{
        if(msg.sender == owner){
            count++;
        }
    }
    
    function getCounter() public view returns(uint){
        return count;
    }
}
