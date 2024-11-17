# Traffic Violation Smart Contract

A Solidity smart contract for managing traffic violations and fines on the Scroll Sepolia testnet.

## Contract Address
Verified Contract Address (Scroll Sepolia): [`0x5F36A20D3D06B7bfc63a59c3A566489907938F5c`](https://sepolia.scrollscan.dev/address/0x5F36A20D3D06B7bfc63a59c3A566489907938F5c)

## Features

- Register vehicle plate numbers with owner IC and email
- Record traffic violations with details like:
  - Plate number
  - Vehicle color and brand
  - Timestamp
  - GPS coordinates
  - Fine amount
- Pay traffic fines
- View violation history and unpaid fines
- Admin functions for managing the system

## Core Functions

- `registerPlateNumber`: Register a new plate number with owner details
- `addViolationRecord`: Add a new traffic violation record
- `payFine`: Pay outstanding fines for violations
- `getTotalUnpaidFines`: Get total unpaid fines for a plate number
- `getAllViolationsForPlateNumber`: Get complete violation history
- `getEmailByPlateNumber`: Get registered email for notifications

## Admin Functions

- `setDefaultFineAmount`: Set the default fine amount
- `withdrawFunds`: Withdraw collected fines
- `onlyOwner` modifier for admin functions

## Events

- `ViolationRecorded`: Emitted when new violation is recorded
- `FinePaid`: Emitted when a fine is paid
- `PlateNumberRegistered`: Emitted when new plate number is registered

## License
MIT
