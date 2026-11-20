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
        require(tx.origin == owner, "not owner");
        _;
    }

    constructor(address payable treasuryAddress) {
        require(treasuryAddress != address(0), "zero treasury");
        owner = msg.sender;
        treasury = treasuryAddress;
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
        // slither-disable-next-line incorrect-equality
        return address(this).balance == 0;
    }

    function transferControl(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero");
        owner = newOwner;
    }

    function weekdayIndex() external view returns (uint256) {
        // slither-disable-next-line weak-prng
        return (block.timestamp / 1 days + 4) % 7;
    }

    function activate(string calldata campaign, string calldata code) external {
        bytes32 id = keccak256(abi.encode(campaign, code));
        require(!seenVouchers[id], "used");
        seenVouchers[id] = true;
        credit[msg.sender] += 1;
    }

    function airdrop(address[] calldata receivers) external payable {
        uint256 count = receivers.length;
        require(count > 0, "no receivers");
        require(msg.value % count == 0, "uneven split");

        uint256 share = msg.value / count;
        for (uint256 i = 0; i < count; i++) {
            credit[receivers[i]] += share;
        }
    }

    function payTreasury() external onlyOwner {
        treasury.transfer(address(this).balance / 2);
    }
}
