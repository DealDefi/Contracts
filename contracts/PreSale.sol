pragma solidity 0.6.2;

import "openzeppelin-solidity/contracts/access/Ownable.sol";
import "openzeppelin-solidity/contracts/utils/Address.sol";
import "openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol";
import "./Token.sol";

contract PreSale is ReentrancyGuard, Ownable {

    using Address for address payable;

    ERC20Token public token;

    /// Sale phases timings.
    ///
    /// Phase 1 starts from Monday, 02-Nov-20 08:00:00 UTC and end at Wednesday, 04-Nov-20 07:59:59 UTC
    /// while token rate during this phase is ~ 0.000077 i.e 1 ETH = 13000 tokens.
    ///
    /// Phase 2 starts from Wednesday, 04-Nov-20 08:00:00 UTC and end at Friday, 06-Nov-20 07:59:59 UTC
    /// while token rate during this phase is ~ 0.00009 i.e 1 ETH = 11000 tokens.
    ///
    /// Phase 3 starts from Friday, 06-Nov-20 08:00:00 UTC and end at Sunday, 08-Nov-20 08:00:00 UTC
    /// while token rate during this phase is ~ 0.00011 i.e 1 ETH = 9000 tokens.

    uint256 constant public PHASE_ONE_START_TIME = 1604304000; /// Monday, 02-Nov-20 08:00:00 UTC
    uint256 constant public PHASE_TWO_START_TIME = 1604476800; /// Wednesday, 04-Nov-20 08:00:00 UTC
    uint256 constant public PHASE_THREE_START_TIME = 1604649600; /// Friday, 06-Nov-20 08:00:00 UTC
    uint256 constant public PHASE_THREE_END_TIME = 1604822400; /// Sunday, 08-Nov-20 08:00:00 UTC
    
    /// Multiplier to provide precision.
    uint256 constant public MULTIPLIER = 10 ^ 18;

    /// Rates for different phases of the sale.
    uint256 constant public PHASE_ONE_RATE = 13000 * MULTIPLIER;  /// i.e 13000 tokens = 1 ETH.
    uint256 constant public PHASE_TWO_RATE = 11000 * MULTIPLIER;  /// i.e 11000 tokens = 1 ETH.
    uint256 constant public PHASE_THREE_RATE = 9000 * MULTIPLIER;  /// i.e 9000 tokens = 1 ETH.

    /// Address receives the funds collected from the sale.
    address public fundsReceiver;
    /// Boolean variable to provide the status of sale finalization.
    bool public isSaleFinalized;

    /// Event emitted when tokens are bought by the investor.
    event TokensBought(address indexed _beneficiary, uint256 _amount);
    /// Even emitted when sale is finalized.
    event SaleFinalized();

    /// @dev fallback function to receives ETH.
    receive() external payable {
        // calls `buyTokens()`
        buyTokens();
    }


    /// @dev Constructor to set initial values for the contract.
    /// 
    /// @param _tokenAddress Address of the token that gets distributed.
    /// @param _fundsReceiver Address that receives the funds collected from the sale.
    constructor(address _tokenAddress, address _fundsReceiver) public {
        // 0x0 is not allowed. It is only a sanity check.
        _checkForZeroAddress(_tokenAddress);
        _checkForZeroAddress(_fundsReceiver);
        // Assign variables. 
        token = ERC20Token(_tokenAddress);
        fundsReceiver = _fundsReceiver;

        // Set finalize status to false.
        isSaleFinalized = false;
    }


    /// @dev Used to buy tokens using ETH. It is only allowed to call when sale is running.
    /// ex - Alice sends 2 ETH.
    /// If Phase 1 is running Alice receives 2 * 13000 i.e 26000 tokens whilst `fundsReceiver`
    /// will get 2 ETH.
    /// If Phase 2 is running Alice receives 2 * 11000 i.e 22000 tokens whilst `fundsReceiver`
    /// will get 2 ETH.
    /// If Phase 3 is running Alice receives 2 * 11000 i.e 9000 tokens whilst `fundsReceiver`
    /// will get 2 ETH.
    function buyTokens() public payable nonReentrant {
        // Check whether sale is in running or not.
        _hasSaleRunning();

        // Fetch the current rate as per the phases.
        uint256 rate = getCurrentRate();
        // Calculate the amount of tokens to sale.
        uint256 tokensToSale = rate * msg.value;

        // Sends funds to funds collector wallet.
        address(uint160(fundsReceiver)).sendValue(msg.value);
        // Tokens get transfered from this contract to the buyer.
        token.transfer(msg.sender, tokensToSale);
        // Emit event.
        emit TokensBought(msg.sender, tokensToSale);
    }

    /// @dev Finalize the sale. Only be called by the owner of the contract.
    /// It can only be called after the sale ends and it burns the remaining
    /// tokens after completing the sale duration.
    function finalizeSale() public onlyOwner {
        // Ensure sale ended.
        require(now > PHASE_THREE_END_TIME, "Sale has not end yet");
        // Should not already be finalized.
        require(!isSaleFinalized, "Already finalized");
        // Fetch the remaining tokens those are owned by the contract.
        uint256 remainingTokens = token.balanceOf(address(this));
        // Call burn function to burn the remaining tokens amount.
        token.burn(remainingTokens);
        // Set finalized status to be true as it not repeatatedly called.
        isSaleFinalized = true;
        // Emit even.
        emit SaleFinalized();
    }


    /// @dev Public getter to fetch the current rate as per the running phase.
    function getCurrentRate() public view returns(uint256 _rate) {
        uint256 currentTime = now;
        // Phase 1
        if (currentTime >= PHASE_ONE_START_TIME && currentTime < PHASE_TWO_START_TIME) {
            return PHASE_ONE_RATE;
        }
        // Phase 2
        else if (currentTime >= PHASE_TWO_START_TIME && currentTime < PHASE_THREE_START_TIME) {
            return PHASE_TWO_RATE;
        }
        // Phase 3
        else if (currentTime >= PHASE_THREE_START_TIME && currentTime < PHASE_THREE_END_TIME) {
            return PHASE_TWO_RATE;
        }
        // Return 0 when there is no phase running.
        return uint256(0);
    }

    function _hasSaleRunning() internal view {
        require(now >= PHASE_ONE_START_TIME, "Sale has yet to be started");
        require(now <= PHASE_THREE_END_TIME, "Sale has ended");
    }

    function _checkForZeroAddress(address _target) internal pure {
        require(_target != address(0), "Invalid address");
    }

}