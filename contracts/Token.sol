pragma solidity 0.6.2;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";

contract ERC20Token is Ownable, ERC20Burnable {

    using Address for address;

    /// Constant that holds token distribution.
    uint256 constant public MULTIPLIER = 10 ^ 18;
    uint256 constant public TEAM_ALLOCATION = 1000000 * MULTIPLIER;
    uint256 constant public MARKETING_ALLOCATION = 1000000 * MULTIPLIER;
    uint256 constant public REWARDS_ALLOCATION = 40000000 * MULTIPLIER;
    uint256 constant public PRESALE_ALLOCATION = 8000000 * MULTIPLIER;

    /// Timestamp at which locking duration of tokens will start. i.e Sunday, 08-Nov-20 10:00:00 UTC 
    uint256 constant public LOCK_START_TIME = 1604829600;
    /// Timestamp at which rewards tokens get released. i.e Sunday, 15-Nov-20 10:00:00 UTC. 
    uint256 constant public REWARDS_ALLOCATION_RELEASE_AT = 1605434400;
    /// Timestamp at which mearketing tokens get released. i.e Monday, 08-Mar-21 10:00:00 UTC
    uint256 constant public MARKETING_ALLOCATION_RELEASE_AT = 1615197600;
    /// Timestamp at which team tokens get released. i.e Saturday, 08-May-21 10:00:00 UTC
    uint256 constant public TEAM_ALLOCATION_RELEASE_AT = 1620468000;

    /// Boolean variable to know whether team tokens are allocated or not.
    bool public isTeamTokensAllocated;
    /// Boolean variable to know whether marketing tokens are allocated or not.
    bool public isMarketingTokensAllocated;
    /// Boolean variable to know whether rewards tokens are allocated or not.
    bool public isRewardsTokensAllocated;
    /// Private variable to switch off the minting.
    bool private _mintingClosed;

    /// Even emitted when tokens get unlocked.
    event TokensUnlocked(address indexed _beneficiary, uint256 _amount);

    /// @dev Contructor to set the token name & symbol.
    ///
    /// @param _tokenName Name of the token.
    /// @param _tokenSymbol Symbol of the token.
    constructor(string memory _tokenName, string memory _tokenSymbol) ERC20(_tokenName, _tokenSymbol) public {
        // Set initial variables
        isTeamTokensAllocated = false;
        isMarketingTokensAllocated = false;
        isRewardsTokensAllocated = false;
        _mintingClosed = false;
    }

    /// @dev Used to mint initial number of tokens. Called only by the owner of the contract.
    /// This is a one time operation performed by the token issuer.
    ///
    /// @param _saleContractAddress Address of the pre sale contract.
    function initialMint(address _saleContractAddress) public onlyOwner {
        require(!_mintingClosed, "Intital minting closed");
        require(_saleContractAddress.isContract(), "Not a valid contract address");
        // Close the minting.
        _mintingClosed = true;
        // Mint Presale tokens to the sale contract address.
        _mint(_saleContractAddress, PRESALE_ALLOCATION);

        // Mint tokens for locking allocation.
        // Compute total amounts of token. Avoiding SafeMath as values are deterministics.
        uint256 _amount = TEAM_ALLOCATION + MARKETING_ALLOCATION + REWARDS_ALLOCATION;
        _mint(address(this), _amount);
    }

    /// @dev Used to unlock tokens, Only be called by the contract owner & also received by the owner as well.
    /// It commulate the `releaseAmount` as per the time passed and release the
    /// commulated number of tokens.
    /// e.g - Owner call this function at Monday, 08-Mar-21 10:00:00 UTC
    /// then commulated amount of tokens will be  REWARDS_ALLOCATION + MARKETING_ALLOCATION
    function unlockTokens() external onlyOwner {
        uint256 currentTime = now;
        uint256 releaseAmount = 0;
        if (!isRewardsTokensAllocated && currentTime >= REWARDS_ALLOCATION_RELEASE_AT) {
            releaseAmount = REWARDS_ALLOCATION;
            isRewardsTokensAllocated = true;
        }
        if (!isMarketingTokensAllocated && currentTime >= MARKETING_ALLOCATION_RELEASE_AT) {
            releaseAmount += MARKETING_ALLOCATION;
            isMarketingTokensAllocated = true;
        }
        if (!isTeamTokensAllocated && currentTime >= TEAM_ALLOCATION_RELEASE_AT)  {
            releaseAmount += TEAM_ALLOCATION;
            isTeamTokensAllocated = true;
        }
        // Transfer funds to owner.
        transfer(_msgSender(), releaseAmount);
        emit TokensUnlocked(_msgSender(), releaseAmount);
    }

}