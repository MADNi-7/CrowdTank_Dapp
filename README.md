# CrowdTank Smart Contract

This repository contains the CrowdTank.sol smart contract developed as part of my internship with NullClass. The contract is a simplified decentralized crowdfunding platform built with Solidity.

# Overview

CrowdTank allows approved project creators to:

1. Create crowdfunding projects
2. Accept contributions from users
3. Withdraw funds if funding goals are met
4. Allow contributors to withdraw if goals aren't met

--------------------------------------------------------------------------------------------------------

# Completed Internship Tasks
--------------------------------------------------------------------------------------------------------

 Task 1: Add Events for Withdraw Functions

 Implemented FundsWithdrawn event, emitted in:

1. userWithdrawFinds(uint projectId) 
    Triggered when a user withdraws their contributions for an unfunded project.

2. adminWithdrawFunds(uint projectId) 
    Triggered when the project creator withdraws after successful funding.

---------------------------------------------------------------------------------------------------------

Task 2: Added deadline extension functionality for creators only

1. extendDeadline(uint _projectId, uint _extraTimeInSeconds)
    Only project creator can extend the deadline.

----------------------------------------------------------------------------------------------------------

Task 3: Admin Functionality for Project Creators

1. Added admin as contract deployer (via constructor)

2. Add creators using addCreator(address)

3. Remove creators using removeCreator(address)

4. Modified createProject() so only added creators can create projects

----------------------------------------------------------------------------------------------------------



* Completed all assigned tasks during the NullClass internship  






