// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AutoScholarship {

    struct Scholarship {
        address sponsor;
        address student;
        uint256 amount;
        uint256 targetCgpa; // scaled by 100 (e.g., 350 = 3.50 CGPA)
        bool released;
        uint256 createdAt;
    }

    mapping(uint256 => Scholarship) public scholarships;
    mapping(address => uint256) public studentCgpa; // scaled by 100
    uint256 public scholarshipCount;
    address public immutable admin;

    event ScholarshipCreated(uint256 indexed id, address sponsor, address student, uint256 amount, uint256 targetCgpa);
    event CgpaUpdated(address indexed student, uint256 newCgpa);
    event FundsReleased(uint256 indexed id, address student, uint256 amount);
    event FundsRefunded(uint256 indexed id, address sponsor, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createScholarship(address _student, uint256 _targetCgpa) external payable {
        require(msg.value > 0, "Amount must be greater than 0");
        require(_student != address(0), "Invalid student address");
        require(_targetCgpa > 0 && _targetCgpa <= 400, "Invalid target CGPA");

        scholarshipCount++;
        scholarships[scholarshipCount] = Scholarship({
            sponsor: msg.sender,
            student: _student,
            amount: msg.value,
            targetCgpa: _targetCgpa,
            released: false,
            createdAt: block.timestamp
        });

        emit ScholarshipCreated(scholarshipCount, msg.sender, _student, msg.value, _targetCgpa);

        // Auto-release if student already meets target
        _checkAndRelease(scholarshipCount);
    }

    function updateCgpa(address _student, uint256 _newCgpa) external onlyAdmin {
        require(_student != address(0), "Invalid student address");
        require(_newCgpa <= 400, "Invalid CGPA");

        studentCgpa[_student] = _newCgpa;

        emit CgpaUpdated(_student, _newCgpa);

        // Check all scholarships for this student
        for (uint256 i = 1; i <= scholarshipCount; i++) {
            if (scholarships[i].student == _student && !scholarships[i].released) {
                _checkAndRelease(i);
            }
        }
    }

    function _checkAndRelease(uint256 _scholarshipId) internal {
        Scholarship storage scholarship = scholarships[_scholarshipId];

        if (!scholarship.released && studentCgpa[scholarship.student] >= scholarship.targetCgpa) {
            scholarship.released = true;
            uint256 amount = scholarship.amount;
            scholarship.amount = 0; // Prevent reentrancy

            (bool success, ) = scholarship.student.call{value: amount}("");
            require(success, "Transfer failed");

            emit FundsReleased(_scholarshipId, scholarship.student, amount);
        }
    }

    function refundScholarship(uint256 _scholarshipId) external onlyAdmin {
        Scholarship storage scholarship = scholarships[_scholarshipId];
        require(!scholarship.released, "Scholarship already released");
        require(scholarship.amount > 0, "No funds to refund");

        scholarship.released = true;
        uint256 amount = scholarship.amount;
        scholarship.amount = 0;

        (bool success, ) = scholarship.sponsor.call{value: amount}("");
        require(success, "Refund failed");

        emit FundsRefunded(_scholarshipId, scholarship.sponsor, amount);
    }

    function getScholarship(uint256 _id) external view returns (Scholarship memory) {
        return scholarships[_id];
    }

    function getStudentCgpa(address _student) external view returns (uint256) {
        return studentCgpa[_student];
    }
}
