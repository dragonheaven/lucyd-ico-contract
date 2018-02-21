pragma solidity ^0.4.0;

import './StandardToken.sol';

contract BurnableToken is StandardToken {
    // How many tokens we burned
    event Burned(address burner, uint burnedAmount);

    // Burn extra tokens from a balance.
    function burn(uint burnAmount) public {
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(burnAmount);
        totalSupply = totalSupply.sub(burnAmount);
        Burned(burner, burnAmount);
    }
}
