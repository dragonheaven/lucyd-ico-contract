pragma solidity ^0.4.0;

import './lib/MintableToken.sol';
/**
   Contract for Lucyd Token
*/
contract LucydToken is MintableToken {

    string public name = "Lucyd Token";

    string public symbol = "LCD";

    uint8 public decimals = 18;

    event NewToken(address _token);

    function LucydToken() public {
        NewToken(address(this));
    }
}
