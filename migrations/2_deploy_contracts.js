var SafeMath = artifacts.require('./SafeMath.sol');
var Ownable = artifacts.require('./Ownable.sol');
var LucydToken = artifacts.require('./LucydToken.sol');
var LucydTokenPresale = artifacts.require('./LucydTokenPresale.sol');

module.exports = function(deployer) {
    let cmAddress = '0x627306090abab3a6e1400e9345bc60c78a8bef57';
    deployer.deploy(SafeMath);
    deployer.deploy(Ownable);

    deployer.deploy(LucydToken).then(token => deployer.deploy(LucydTokenPresale, token.address, cmAddress).then(presale => {
        token.setController.sendTransaction
    }))
    deployer.deploy(LucydTokenPresale, cmAddress, 1511615068)
        .then(LucydTokenPresale.deployed)
        .then(presale => deployer.deploy(LucydToken, presale.address).then(token => {
                presale.initPresale(token.address);
            }
        ));
};
