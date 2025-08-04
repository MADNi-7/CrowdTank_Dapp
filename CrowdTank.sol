// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract CrowdTank {

     // Admin address and creators list
    address public admin;
    mapping(address => bool) public isCreator;

    // struct to store project details
    struct Project {
        address creator;
        string name;
        string description;
        uint fundingGoal;
        uint deadline;
        uint amountRaised;
        bool funded;
    }
    // projectId => project details
    mapping(uint => Project) public projects;
    // projectId => user => contribution amount/funding amount 
    mapping(uint => mapping(address => uint)) public contributions;

    // projectId => whether the id is used or not
    mapping(uint => bool) public isIdUsed;


    // Constructor: sets the deployer as the admin
    constructor() {
        admin = msg.sender;
    }


    // events
    event ProjectCreated(uint indexed projectId, address indexed creator, string name, string description, uint fundingGoal, uint deadline);
    event ProjectFunded(uint indexed projectId, address indexed contributor, uint amount);
    // withdrawerType = "user" ,= "admin"
    event FundsWithdrawn(uint indexed projectId, address indexed withdrawer, uint amount, string withdrawerType);

    event DeadlineExtended(uint indexed projectId, uint newDeadline);


    // create project by a creator
    // external public internal private
    function createProject(string memory _name, string memory _description, uint _fundingGoal, uint _durationSeconds, uint _id) external {
        require(isCreator[msg.sender], "Only approved creators can create projects");
        require(!isIdUsed[_id], "Project Id is already used");
        isIdUsed[_id] = true;
        projects[_id] = Project({
        creator : msg.sender,
        name : _name,
        description : _description,
        fundingGoal : _fundingGoal,
        deadline : block.timestamp + _durationSeconds,
        amountRaised : 0,
        funded : false
        });
        emit ProjectCreated(_id, msg.sender, _name, _description, _fundingGoal, block.timestamp + _durationSeconds);
    }


    // Admin-only: Add a creator
    function addCreator(address _creator) external {
        require(msg.sender == admin, "Only admin can add creators");
        isCreator[_creator] = true;
    }

    // Admin-only: Remove a creator
    function removeCreator(address _creator) external {
        require(msg.sender == admin, "Only admin can remove creators");
        isCreator[_creator] = false;
    }



    function fundProject(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(block.timestamp <= project.deadline, "Project deadline is already passed");
        require(!project.funded, "Project is already funded");
        require(msg.value > 0, "Must send some value of ether");
        project.amountRaised += msg.value;
        contributions[_projectId][msg.sender] += msg.value;
        emit ProjectFunded(_projectId, msg.sender, msg.value);
        if (project.amountRaised >= project.fundingGoal) {
            project.funded = true;
        }
    }

    function userWithdrawFunds(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        require(project.amountRaised < project.fundingGoal, "Funding goal is reached, user can't withdraw");
        uint fundContributed = contributions[_projectId][msg.sender];

        // Check that user actually contributed something
        require(fundContributed > 0, "No funds to withdraw");

        // Reset user's contribution before transfer to avoid re-entrancy
        contributions[_projectId][msg.sender] = 0;
        payable(msg.sender).transfer(fundContributed);

        // Emit event for user's withdrawal
        emit FundsWithdrawn(_projectId, msg.sender, fundContributed, "user");
    }



    function adminWithdrawFunds(uint _projectId) external payable {
        Project storage project = projects[_projectId];
        uint totalFunding = project.amountRaised;
        require(project.funded, "Funding is not sufficient");
        require(project.creator == msg.sender, "Only project admin can withdraw");
        require(project.deadline <= block.timestamp, "Deadline for project is not reached");
        // Make sure there are funds to withdraw
        require(totalFunding > 0, "No funds to withdraw");
        // Reset project funds before transfer to avoid re-entrancy
        project.amountRaised = 0;
        payable(msg.sender).transfer(totalFunding);

        // Emit event for admin's withdrawal
        emit FundsWithdrawn(_projectId, msg.sender, totalFunding, "admin");
    }
    

        function extendDeadline(uint _projectId, uint _extraTimeInSeconds) external {
        Project storage project = projects[_projectId];
        require(msg.sender == project.creator, "Only project creator can extend deadline");
        require(block.timestamp < project.deadline, "Cannot extend after deadline passed");
        // Increase the deadline
        project.deadline += _extraTimeInSeconds;

        // Emit an event to record this extension
        emit DeadlineExtended(_projectId, project.deadline);
    }

}