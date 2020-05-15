pragma solidity  ^0.6.6;

contract SensorImp{
    address owner;
    uint256 numMeasurements;
    mapping(string => Measurement) public measurements;
    mapping(uint256 => string) public indexMeasurements;
    mapping(address => bool) admins;
    mapping(address => bool) peers;

    struct Measurement{
        string ID;
        string Sensor;
        string Value;
        string Timestamp;
        string Location;
        string PhysicalQuantity;
    }

    modifier onlyAdmin(){
        require(admins[msg.sender] == true, "Only admins allowed.");
        _;
    }

    modifier onlyPeer(){
        require(peers[msg.sender] != true, "Only peers allowed.");
        _;
    }

    constructor() public{
        admins[msg.sender] = true;
        peers[msg.sender] = true;
        numMeasurements = 0;
    }

    function store(
                    string memory _ID,
                    string memory _Sensor,
                    string memory _Value,
                    string memory _Timestamp,
                    string memory _Location,
                    string memory _PhysicalQuantity
                    ) public onlyPeer
    {
        numMeasurements++;
        indexMeasurements[numMeasurements] = _ID;
        measurements[_ID] = Measurement(_ID,
                                        _Sensor,
                                        _Value,
                                        _Timestamp,
                                        _Location,
                                        _PhysicalQuantity);
    }

    function read(uint256 index) public view returns (
                                        string memory,
                                        string memory,
                                        string memory,
                                        string memory,
                                        string memory,
                                        string memory)
        {
        string memory tempID = indexMeasurements[index];
        Measurement storage info = measurements[tempID];
        return (info.ID, info.Sensor, info.Value, info.Timestamp, info.Location, info.PhysicalQuantity);
    }

    function read(string memory _ID) public view returns(
                                                        string memory,
                                                        string memory,
                                                        string  memory,
                                                        string  memory,
                                                        string memory,
                                                        string memory)
        {
        Measurement memory info = measurements[_ID];
        return (info.ID, info.Sensor, info.Value, info.Timestamp, info.Location, info.PhysicalQuantity);
    }

    function get_measurements() public view returns (uint256){
        return numMeasurements;
    }

    function addAdmin(address _wallet) public onlyAdmin{
        admins[_wallet] = true;
    }

    function removeAdmin(address _wallet) public onlyAdmin{
        require(admins[_wallet] = true, "Must be an admin.");
        delete(admins[_wallet]);
    }

    function addPeer(address _wallet) public onlyAdmin{
        peers[_wallet] = true;
    }

    function removePeer(address _wallet) public onlyAdmin{
        require(peers[_wallet] = true, "Must be a peer.");
        delete(peers[_wallet]);
    }
}
