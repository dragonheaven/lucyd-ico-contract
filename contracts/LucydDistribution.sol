pragma solidity ^0.4.0;

import './LucydToken.sol';
import './VestingVault.sol';
import './installed/Claimable.sol';
import './installed/lib/SafeMath.sol';

/**
 * Contract for distribution of tokens
 */
contract LucydTokenDistribution is Claimable {
    using SafeMath for uint256;

    struct ContributorInfo {
        address withdrawAddress;
        uint tokenAmount;
    }

    LucydToken public token;
    VestingVault public vestingVault;
    TeamVault public teamVault;

    address public walletLiquidity;
    address public walletTeam;
    address public walletCommunity;
    address public walletAdvisor;

    uint256 public MAX_TOKEN_SUPPLY = 500000000 * 10**18;

    mapping (string => ContributorInfo) contributors;

    event TokenMinted(address _holder, uint _amount, string _customerId);

    function LucydTokenDistribution(
        LucydToken _token,
        VestingVault _vestingVault,
        TeamVault _teamVault,
        address _walletLiquidity,
        address _walletTeam,
        address _walletCommunity,
        address _walletAdvisor
    ) public {
        require(address(_token) != 0x0);
        require(address(_vestingVault) != 0x0);
        require(address(_teamVault) != 0x0);
        require(_walletLiquidity != 0x0);
        require(_walletTeam != 0x0);
        require(_walletCommunity != 0x0);
        require(_walletAdvisor != 0x0);

        token = _token;
        vestingVault = _vestingVault;
        teamVault = _teamVault;

        walletLiquidity = _walletLiquidity;
        walletTeam = _walletTeam;
        walletCommunity = _walletCommunity;
        walletAdvisor = _walletAdvisor;
    }

    function allocateNormalContributor(address _holder, uint _amount, string _customerId) public onlyOwner {
        uint weiAmount = _amount * 10**18;
        token.mint(_holder, weiAmount);
        contributors[_customerId] = ContributorInfo(_holder, _amount);
        TokenMinted(_holder, weiAmount, _customerId);
    }

    function allocateVestedContributor(address _holder, uint _amount, uint _level, string _customerId) public onlyOwner {
        uint weiAmount = _amount * 10**18;
        token.mint(vestingVault, weiAmount);
        vestingVault.grant(_holder, weiAmount, _level, now, now + 180 days, _customerId);
        TokenMinted(_holder, weiAmount, _customerId);
    }

    function allocateTeam() public onlyOwner {
        uint weiAmount = MAX_TOKEN_SUPPLY.div(10);
        token.mint(teamVault, weiAmount);
        teamVault.startVesting(walletTeam, weiAmount, now, now + 24 * 30 days);
        TokenMinted(address(teamVault), weiAmount, "CM-Team");
    }

    function allocateExtra() public onlyOwner {
        token.mint(walletLiquidity, MAX_TOKEN_SUPPLY.mul(20).div(100));
        token.mint(walletCommunity, MAX_TOKEN_SUPPLY.mul(75).div(1000));
        token.mint(walletAdvisor, MAX_TOKEN_SUPPLY.mul(25).div(1000));

        TokenMinted(walletLiquidity, MAX_TOKEN_SUPPLY.mul(20).div(100), "CM-Liquidity");
        TokenMinted(walletCommunity, MAX_TOKEN_SUPPLY.mul(75).div(1000), "CM-Community");
        TokenMinted(walletAdvisor, MAX_TOKEN_SUPPLY.mul(25).div(1000), "CM-Advisor");
    }

    function finalize() public onlyOwner {
        token.finishMinting();
    }

    function claimTokenOwnership() public onlyOwner {
        token.claimOwnership();
    }

    function transferBackTokenOwnership() public onlyOwner {
        token.transferOwnership(owner);
    }

    function claimVestingVaultOwnership() public onlyOwner {
        vestingVault.claimOwnership();
    }

    function transferBackVestingVaultOwnership() public onlyOwner {
        vestingVault.transferOwnership(owner);
    }

    function claimTeamVaultOwnership() public onlyOwner {
        teamVault.claimOwnership();
    }

    function transferBackTeamVaultOwnership() public onlyOwner {
        teamVault.transferOwnership(owner);
    }
}
