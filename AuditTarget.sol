// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// NT547 - Lab 06 - Hop dong rieng cua MSSV 24520084. KHONG deploy len mainnet.

interface IERC20Like {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract CrowdFund_0084 {
    address public owner;
    mapping(address => uint256) public credit;
    mapping(bytes32 => bool) public seenVouchers;
    address payable internal treasury;

    event Deposited(address indexed who, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function contribute() external payable {
        credit[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function ownerWithdraw(uint256 amount) external onlyOwner {
        (bool ok, ) = payable(owner).call{value: amount}("");
        require(ok, "withdraw failed");
    }

    function vaultDrained() external view returns (bool) {
        return address(this).balance == 0;
    }

    function transferControl(address newOwner) external {
        require(tx.origin == owner, "not owner");
        require(newOwner != address(0), "zero");
        owner = newOwner;
    }

    function weekdayIndex() external view returns (uint256) {
        return (block.timestamp / 1 days + 4) % 7;
    }

    function activate(string calldata campaign, string calldata code) external {
        bytes32 id = keccak256(abi.encodePacked(campaign, code));
        require(!seenVouchers[id], "used");
        seenVouchers[id] = true;
        credit[msg.sender] += 1;
    }

    function airdrop(address[] calldata receivers) external payable {
        for (uint256 i = 0; i < receivers.length; i++) {
            credit[receivers[i]] += msg.value;
        }
    }

    function payTreasury() external onlyOwner {
        treasury.transfer(address(this).balance / 2);
    }
}
