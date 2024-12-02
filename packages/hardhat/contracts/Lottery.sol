// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LotteryToken} from "./LotteryToken.sol";

/// @title A very simple lottery contract
/// @notice You can use this contract for running a very simple lottery
/// @dev This contract implements a relatively weak randomness source, since there is no cliff period between the randao reveal and the actual usage in this contract
/// @custom:teaching This is a contract meant for teaching only
contract Lottery is Ownable {
    /// @notice Address of the token used as payment for the bets
    LotteryToken public paymentToken;
    /// @notice Amount of tokens given per ETH paid
    uint256 public purchaseRatio;
    /// @notice Amount of tokens required for placing a bet that goes for the prize pool
    uint256 public betPrice;
    /// @notice Amount of tokens required for placing a bet that goes for the owner pool
    uint256 public betFee;
    bool public betsOpen;
    uint256 public prizePool;
    uint256 public betsClosingTime;
    address[] public _slots; 
    uint256 public betFees;
    address public winner;
    mapping(address => uint256)  public prizeAmount;
    uint256 public ownerPool;

     /// @notice Passes when the lottery is at closed state
    modifier whenBetsClosed() {
        require(!betsOpen, "Lottery is open");
        _;
    }

    /// @notice Passes when the lottery is at open state and the current block timestamp is lower than the lottery closing date
    modifier whenBetsOpen() {
        require(
            betsOpen && block.timestamp < betsClosingTime,
            "Lottery is closed"
        );
        _;
    }

    /// @notice Constructor function
    /// @param _tokenName Name of the token used for payment
    /// @param _tokenSymbol Symbol of the token used for payment
    /// @param _purchaseRatio Amount of tokens given per ETH paid
    /// @param _betPrice Amount of tokens required for placing a bet that goes for the prize pool
    /// @param _betFee Amount of tokens required for placing a bet that goes for the owner pool
    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _purchaseRatio,
        uint256 _betPrice,
        uint256 _betFee
    ) Ownable() {
        paymentToken = new LotteryToken(_tokenName, _tokenSymbol);
        purchaseRatio = _purchaseRatio;
        betPrice = _betPrice;
        betFee = _betFee;
    }

   function isOwner(address account) external view returns(bool) {
         return account == owner() ;
   }

    function isWinner(address account) external view returns(bool) {
         return !betsOpen &&  account == winner;
   }

   
   function isLotteryClosed() external view returns(bool) {
         return !betsOpen;
   }
 
   function isPastLotteryClosingTime() external view returns(bool) {
         return _isPastClosingTime();
   }

    function _isPastClosingTime() private view returns(bool) {
         return block.timestamp >= betsClosingTime;
   }

    function tokenBalance(address account) external view returns(uint256) {
         return  paymentToken.balanceOf(account);
   }

    function tokenSymbol() external view returns(string memory) {
         return  paymentToken.symbol();
   }

    /// @notice Opens the lottery for receiving bets
    function openBets(uint256 closingTime) external onlyOwner whenBetsClosed {
        require(
            closingTime > block.timestamp,
            "Closing time must be in the future"
        );
        betsClosingTime = closingTime;
        betsOpen = true;
        winner = address(0);
    }

    /// @notice Gives tokens based on the amount of ETH sent and the purchase ratio
    /// @dev This implementation is prone to rounding problems
    function purchaseTokens() external payable {
        // TODO
        uint256 tokens = ethToTokens(msg.value);
        paymentToken.mint(msg.sender, tokens);
    }

    /// @notice Charges the bet price and creates a new bet slot with the sender's address
    function bet(address sender) public {
        // TODO
      _betMany(1, sender);
    }

    function ethToTokens(uint256 eth) private view returns (uint256){
          return eth * purchaseRatio;
    }

   function _betMany(uint256 times, address sender) private {
        require(times > 0);
        uint256 requiredTokens = times * (betPrice + betFee);
        uint256 availableTokens = paymentToken.balanceOf(sender);
        require(availableTokens >= requiredTokens, "You do not have enough tokens");
        while (times > 0) {
            _slots.push(sender);
            times--;
        }
       prizePool += betPrice * times;
       ownerPool += betFee * times;
       paymentToken.transferFrom(sender,  address(this), requiredTokens);
    }

    /// @notice Calls the bet function `times` times
    function betMany(uint256 times, address sender) external {
       _betMany(times, sender);
     }

    /// @notice Closes the lottery and calculates the prize, if any
    /// @dev Anyone can call this function at any time after the closing time
    function closeLottery() external {
        // TODO
        require(_isPastClosingTime() , "Lottery still active");
        require(betsOpen, "already closed");
        if (_slots.length > 0) {
            uint256 winnerIndex = getRandomNumber() % _slots.length;
            winner = _slots[winnerIndex];
            prizeAmount[winner] += prizePool;
            prizePool = 0;
            delete (_slots);
        }
        betsOpen = false;
    }

    /// @notice Returns a random number calculated from the previous block randao
    /// @dev This only works after The Merge
    function getRandomNumber() internal view returns(uint256) {
        return block.prevrandao;
    }

    /// @notice Withdraws `amount` from that accounts's prize pool
    function prizeWithdraw(uint256 amount, address sender) external {
        // TODO
        require(amount < prizeAmount[sender], "Do not have enough prize tokens" );
       prizeAmount[sender] -= amount; 
       paymentToken.transfer(sender, amount);       
    }

    /// @notice Withdraws `amount` from the owner's pool
    function ownerWithdraw(uint256 amount) external onlyOwner {
        // TODO
          require(amount <= ownerPool, "Not enough fees collected");
        ownerPool -= amount;
           uint256 eth = tokensToEth(amount);
      (bool ok,) =  payable(msg.sender).call{value: eth}("");
      require(ok, "failed to send eth");
    }
    
    function tokensToEth(uint256 amount) private view returns(uint256){
       return amount / purchaseRatio;
    }

    /// @notice Burns `amount` tokens and give the equivalent ETH back to user
    function returnTokens(uint256 amount, address sender) external {
        // TODO
        paymentToken.burnFrom(sender, amount);
        uint256 eth = tokensToEth(amount);
      (bool ok,) =  payable(sender).call{value: eth}("");
      require(ok, "failed to send eth");
    }
}