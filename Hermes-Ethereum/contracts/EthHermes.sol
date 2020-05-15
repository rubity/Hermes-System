pragma solidity  ^0.6.6;
pragma experimental "ABIEncoderV2";

/*
	This chaincode aims to make the requisition, reading and storage
	of data .json that will be sent by another application, written in pyhton, via http. For
	the communication of the application written in python with this chaincode, was used
	the web3py library and geth.

	@author: Ramon Rocha Rezende.
	@date: September/2019
*/

contract EthHermes{
    address owner;
    uint256 numMeasurements;
    uint blockNumber = 0;
    uint pastBlockNumber = 0;
    mapping(uint256 => Measurement) measurements;

    struct ifloat{
        uint256 numerator;
        uint256 denominator;
    }

    struct Measurement{
        uint256 ID;
        string Sensor;
        ifloat Value;
        ifloat Timestamp;
        string Location;
        string PhysicalQuantity;
    }

    constructor() public{
        owner = msg.sender;
        numMeasurements = 0;
        pastBlockNumber = block.number;
        blockNumber = block.number;
    }

    function store(
                    uint256 _ID,
                    string memory _Sensor,
                    ifloat memory _Value,
                    ifloat memory _Timestamp,
                    string memory _Location,
                    string memory _PhysicalQuantity
                    ) public
    {
        pastBlockNumber = blockNumber;
        blockNumber = block.number;
        numMeasurements++;
        measurements[_ID] = Measurement(_ID,
                                        _Sensor,
                                        _Value,
                                        _Timestamp,
                                        _Location,
                                        _PhysicalQuantity);
    }

    function read(uint256 _ID) public view returns(
                                                        uint256,
                                                        string memory,
                                                        ifloat memory,
                                                        ifloat memory,
                                                        string memory,
                                                        string memory)
        {
        Measurement memory info = measurements[_ID];
        return (info.ID, info.Sensor, info.Value, info.Timestamp, info.Location, info.PhysicalQuantity);
    }

    function get_measurements() public view returns (uint256){
        return numMeasurements;
    }

    function getLastBlock() public view returns(uint){
        return pastBlockNumber;
    }

    function getBlock() public view returns(uint){
        return blockNumber;
    }

}
