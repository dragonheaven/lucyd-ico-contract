pragma solidity ^0.4.0;

import './LucydToken.sol';
import './lib/Claimble.sol';

/**
* VestingVault Contract that will hold vested tokens
*/
contract VestingVault is Claimable {
    using SafeMath for uint256;

    struct Grant {
        uint256 value;
        uint    level;
        uint256 start;
        uint256 end;
        uint256 transferred;
    }

    LucydToken public token;
    address[] public vestedAddresses;

    mapping (address => Grant) public grants;

    uint public vestingSlide;
    uint public totalVestedTokens;

    event NewGrant(address _holder, uint _amount, string _customerId);
    event NewRelease(address _holder, uint _amount);

    function VestingVault(LucydToken _token, uint _slide) public {
        require(_token != address(0));
        token = _token;
        vestingSlide = _slide * 1 days;
    }

    function grant(address _to, uint _value, uint _level, uint _start, uint _end, string _customerId) external onlyOwner {
        require(_to != address(0));
        require(_value > 0);

        // make sure a single address can be granted tokens only once.
        require(grants[_to].value == 0);

        // make sure start is before the end
        require(_start < _end);
        grants[_to] = Grant({
            value: _value,
            level: _level,
            start: _start,
            end:   _end,
            transferred: 0
            });

        vestedAddresses.push(_to);

        NewGrant(_to, _value, _customerId);
        totalVestedTokens = totalVestedTokens.add(_value);
    }

    function transferableTokens(address _holder, uint256 _time) public constant returns (uint256) {
        Grant storage grant = grants[_holder];

        if (grant.value == 0) {
            return 0;
        }

        return calculateTransferableTokens(grant, _time);
    }

    function calculateTransferableTokens(Grant _grant, uint256 _time) private constant returns (uint256) {
        // before cliff date (first vesting slide)
        if (_grant.start + vestingSlide > _time) {
            return 0;
        }

        // after vesting period ends
        if (_grant.end < _time) {
            return _grant.value;
        }

        if ((_grant.start + vestingSlide <= _time) && (_time < _grant.start + 2 * vestingSlide)) {
            if (_grant.level == 1) {
                // 20% of tokens will be available after 1 vestingSlide for contributors purchased at price 0.03 eur
                return _grant.value.mul(20).div(100);
            } else if (_grant.level == 2) {
                // 33% of tokens will be available after 1 vestingSlide for contributors purchased at price 0.05 eur
                return _grant.value.mul(33).div(100);
            }
        }
    }

    function release() public onlyOwner {
        for(uint i = 0; i < vestedAddresses.length; i++) {
            address holder = vestedAddresses[i];
            if (holder != address(0)) {
                Grant storage grant = grants[holder];

                require(grant.value > 0);

                uint256 vested = calculateTransferableTokens(grant, now);
                if (vested == 0) {
                    return;
                }

                uint256 transferable = vested.sub(grant.transferred);

                if (transferable == 0) {
                    return;
                }

                grant.transferred = grant.transferred.add(transferable);
                totalVestedTokens = totalVestedTokens.sub(transferable);
                token.transfer(holder, transferable);

                NewRelease(holder, transferable);
            }
        }
    }
}
