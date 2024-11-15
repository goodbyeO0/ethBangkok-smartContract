// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TrafficViolation {
    address public owner;
    uint256 public defaultFineAmount = 0.01 ether;

    struct Record {
        string plateNumber;
        string color;
        string brand;
        string timestamp;
        bool isPaid;
        uint256 fineAmount;
    }

    // Mapping IC number to plate numbers owned
    mapping(string => string[]) public icToPlateNumbers;

    // Mapping plate number to owner's IC
    mapping(string => string) public plateNumberToIC;

    // Mapping plate number to violation records
    mapping(string => Record[]) public violationRecords;

    // Events
    event ViolationRecorded(string plateNumber, uint256 timestamp);
    event FinePaid(string plateNumber, uint256 amount, uint256 timestamp);
    event PlateNumberRegistered(string icNumber, string plateNumber);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Register plate number to IC
    function registerPlateNumber(
        string memory _icNumber,
        string memory _plateNumber
    ) public onlyOwner {
        require(
            bytes(plateNumberToIC[_plateNumber]).length == 0,
            "Plate number already registered"
        );

        icToPlateNumbers[_icNumber].push(_plateNumber);
        plateNumberToIC[_plateNumber] = _icNumber;

        emit PlateNumberRegistered(_icNumber, _plateNumber);
    }

    // Add violation record
    function addViolationRecord(
        string memory _plateNumber,
        string memory _color,
        string memory _brand,
        string memory _timestamp
    ) public onlyOwner {
        require(
            bytes(plateNumberToIC[_plateNumber]).length > 0,
            "Plate number not registered"
        );

        Record memory newRecord = Record({
            plateNumber: _plateNumber,
            color: _color,
            brand: _brand,
            timestamp: _timestamp,
            isPaid: false,
            fineAmount: defaultFineAmount
        });

        violationRecords[_plateNumber].push(newRecord);

        emit ViolationRecorded(_plateNumber, block.timestamp);
    }

    // Add this new function to get total unpaid fines
    function getTotalUnpaidFines(
        string memory _plateNumber
    ) public view returns (uint256) {
        Record[] memory records = violationRecords[_plateNumber];
        uint256 totalUnpaid = 0;

        for (uint256 i = 0; i < records.length; i++) {
            if (!records[i].isPaid) {
                totalUnpaid += records[i].fineAmount;
            }
        }

        return totalUnpaid;
    }

    // Modify the payFine function to handle multiple unpaid fines
    function payFine(string memory _plateNumber) public payable {
        Record[] storage records = violationRecords[_plateNumber];
        uint256 totalToPay = getTotalUnpaidFines(_plateNumber);
        require(totalToPay > 0, "No unpaid fines");
        require(msg.value >= totalToPay, "Insufficient payment");

        // Mark all unpaid violations as paid
        for (uint256 i = 0; i < records.length; i++) {
            if (!records[i].isPaid) {
                records[i].isPaid = true;
            }
        }

        emit FinePaid(_plateNumber, msg.value, block.timestamp);

        // Return excess payment if any
        if (msg.value > totalToPay) {
            payable(msg.sender).transfer(msg.value - totalToPay);
        }
    }

    // View functions
    function getViolationCount(
        string memory _plateNumber
    ) public view returns (uint256) {
        return violationRecords[_plateNumber].length;
    }

    function getPlateNumbersByIC(
        string memory _icNumber
    ) public view returns (string[] memory) {
        return icToPlateNumbers[_icNumber];
    }

    function getViolationRecord(
        string memory _plateNumber,
        uint256 _index
    )
        public
        view
        returns (
            string memory plateNumber,
            string memory color,
            string memory brand,
            string memory timestamp,
            bool isPaid,
            uint256 fineAmount
        )
    {
        require(
            _index < violationRecords[_plateNumber].length,
            "Invalid index"
        );
        Record memory record = violationRecords[_plateNumber][_index];
        return (
            record.plateNumber,
            record.color,
            record.brand,
            record.timestamp,
            record.isPaid,
            record.fineAmount
        );
    }

    // Admin functions
    function setDefaultFineAmount(uint256 _amount) public onlyOwner {
        defaultFineAmount = _amount;
    }

    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
