pragma solidity ^0.4.0;

/**
 * TeamVault that will holds tokens allocated to Lucyd TeamVault
 */
contract TeamVault is Claimable {
    using SafeMath for uint256;

    LucydToken public token;

    address public withdrawAddress;
    uint256 public value;
    uint256 public transferred;
    uint256 public start;
    uint256 public end;

    event TeamTokenReleased(uint256 _amount, uint256 _time);

    function TeamVault(LucydToken _token) public {
        require(address(_token) != 0);
        token = _token;
    }

    function startVesting(address _withdrawAddress, uint256 _amount, uint256 _start, uint256 _end) external onlyOwner {
        require(_withdrawAddress != 0x0);
        withdrawAddress = _withdrawAddress;
        value = _amount;
        start = _start;
        end = _end;
        transferred = 0;
    }

    function transferableTokens(uint256 _time) public view returns (uint256) {
        uint elapsed = (_time - start) / 180 days;
        if (elapsed < 1) {
            return 0;
        }

        if (_time >= end) {
            return token.balanceOf(this);
        }

        if (elapsed >= 1 && elapsed < 2) {
            return value.div(4);
        } else if (elapsed >= 2 && elapsed < 3) {
            return value.div(2);
        } else if (elapsed >= 3 && elapsed < 4) {
            return value.mul(3).div(4);
        }
    }

    function release() public onlyOwner {
        uint256 vested = transferableTokens(now);
        if (vested == 0) {
            return;
        }

        uint256 transferable = vested.sub(transferred);
        if (transferred == 0) {
            return;
        }

        token.transfer(withdrawAddress, transferable);
        transferred = transferred.add(transferable);

        TeamTokenReleased(transferable, now);
    }
}
