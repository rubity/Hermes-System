pragma solidity  ^0.6.6;

contract Map{
    address owner;
    uint num_measurements;

    mapping(uint => uint) measurements;



    constructor () public{
        owner = msg.sender;
        num_measurements = 1;
        measurements[0] = 99;
    }
    
    function store(uint info) public{
        num_measurements++;
        measurements[num_measurements] = info;
    }

    function read(uint indice) public view returns (uint){
        uint info = measurements[indice];
        return info;
    }

    function get_measurements() public view returns (uint){
        return num_measurements;
    }
}
