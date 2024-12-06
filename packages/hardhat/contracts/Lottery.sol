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
    string tokenSymbol;
    string tokenName;
    address public winner;
    mapping(address => uint256)  public prizeAmount;
    uint256 public ownerPool;

   struct SessionInfo {
     uint256 betPrice;
     uint256 betFee;
     address tokenAddress;
     bool betsOpen;
     uint256 nonce;
     uint256 currentTimeStamp;
     uint256 betsClosingTime;
     bool isOwner;
     uint256 prizeAmount;
     uint256 prizePool;
     uint256 ownerPool;
     uint256 tokenBalance;
     string tokenSymbol;
     string tokenName;
     bool isWinner;
     uint256 maxBets;
     bool isLotteryClosed;
     bool isPastLotteryClosingTime;
     uint256 purchaseRatio;
   }

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
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        paymentToken = new LotteryToken(tokenName,tokenSymbol);
        purchaseRatio = _purchaseRatio;
        betPrice = _betPrice;
        betFee = _betFee;
    }

   function isOwner() public view returns(bool) {
         return msg.sender == owner() ;
   }
   
   function ownerAddress() external view returns(address){
    return owner();
   }

    function senderAddress() external view returns(address){
    return msg.sender;
   }

    function tokenAddress() public view returns(address){
    return address(paymentToken);
   }

    function isWinner() public view returns(bool) {
         return !betsOpen &&  msg.sender == winner;
   }

   function isLotteryClosed() public view returns(bool) {
         return !betsOpen;
   }

    function currentTimeStamp() public view returns (uint256) {
         return block.timestamp;
   }
 
    function isPastClosingTime() public view returns(bool) {
         return block.timestamp >= betsClosingTime;
   }

   function maxBets() public view returns(uint256) {
         uint256 balance = tokenBalance();
         return balance / (betFee + betPrice);
   }

   function tokenBalance() public view returns(uint256) {
         return  paymentToken.balanceOf(msg.sender);
   }
  
    /// @notice Opens the lottery for receiving bets
    function startLottery(uint256 closingTime) external onlyOwner whenBetsClosed {
        require(
            closingTime > block.timestamp,
            "Closing time must be in the future"
        );
        betsClosingTime = closingTime;
        betsOpen = true;
        winner = address(0);
        prizePool = 0;
    }

    /// @notice Gives tokens based on the amount of ETH sent and the purchase ratio
    /// @dev This implementation is prone to rounding problems
    function purchaseTokens() external payable {
        uint256 tokens = ethToTokens(msg.value);
        paymentToken.mint(msg.sender, tokens);
    }

    /// @notice Charges the bet price and creates a new bet slot with the msg.sender's address
    function bet() public whenBetsOpen {
      _betMany(1);
    }

   function nonces(address owner) private view returns(uint256) {
      return paymentToken.nonces(owner);
    }

    function ethToTokens(uint256 eth) private view returns (uint256){
          return eth * purchaseRatio;
    }
 
   function sessionInfo() external view returns(SessionInfo memory){
     bool _isOwner = isOwner();
     uint256 balance = tokenBalance();
     bool isClosed = isLotteryClosed();
     bool pastClosingTime = isPastClosingTime();
     uint256 _maxBets = maxBets();
     bool _isWinner = isWinner();
     address _tokenAddress = tokenAddress();
     uint256 _currentTimeStamp = currentTimeStamp();
     uint256 _nonce = nonces(msg.sender);
     SessionInfo memory info =  SessionInfo({
       betPrice:betPrice,
       currentTimeStamp: _currentTimeStamp,
      betFee:betFee,
      nonce:_nonce,
      betsOpen: betsOpen,
      tokenAddress: _tokenAddress,
      betsClosingTime: betsClosingTime,
      isOwner: _isOwner,
      prizeAmount: prizeAmount[msg.sender],
      prizePool: prizePool,
      ownerPool: ownerPool,
      tokenBalance:balance,
      tokenName:tokenName,
      isWinner: _isWinner,
      tokenSymbol: tokenSymbol,
      isLotteryClosed:isClosed,
      isPastLotteryClosingTime:pastClosingTime,
      maxBets:_maxBets,
      purchaseRatio:purchaseRatio
     });
     return info;
   }

   function _betMany(uint256 times) private {
        require(times > 0);
        uint256 requiredTokens = times * (betPrice + betFee);
        uint256 availableTokens = paymentToken.balanceOf(msg.sender);
        require(availableTokens >= requiredTokens, "You do not have enough tokens");
        uint256 loop = times;
        while (loop > 0) {
            _slots.push(msg.sender);
            loop--;
        }
       prizePool += betPrice * times;
       ownerPool += betFee * times;
       paymentToken.transferFrom(msg.sender,  address(this), requiredTokens);
    }

 /// @notice Calls the bet function `times` times
    function permitBets(address owner,
  address spender,
  uint256 value,
  uint256 deadline,
  uint8 v,
  bytes32 r,
  bytes32 s) external {
        uint256 requiredTokens = value;
        uint256 availableTokens = paymentToken.balanceOf(msg.sender);
        require(availableTokens >= requiredTokens, "You do not have enough tokens");
        paymentToken.permit(owner, spender, value, deadline, v, r, s);
     }

    /// @notice Calls the bet function `times` times
    function betMany(uint256 times) external whenBetsOpen {
       _betMany(times);
     }

    /// @notice Closes the lottery and calculates the prize, if any
    /// @dev Anyone can call this function at any time after the closing time
    function closeLottery() external {
        require(isPastClosingTime() , "Lottery still active");
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
    function prizeWithdraw(uint256 amount) external {
        require(amount <= prizeAmount[msg.sender], "Do not have enough prize tokens" );
       prizeAmount[msg.sender] -= amount; 
       paymentToken.transfer(msg.sender, amount);       
    }

    /// @notice Withdraws `amount` from the owner's pool
    function ownerWithdraw(uint256 amount) external onlyOwner returns(uint256){
          require(amount <= ownerPool, "Not enough fees collected");
        ownerPool -= amount;
           uint256 eth = tokensToEth(amount);
      (bool ok,) =  payable(msg.sender).call{value: eth}("");
      require(ok, "failed to send eth");
      return eth;
    }
    
    function tokensToEth(uint256 amount) private view returns(uint256){
       return amount / purchaseRatio;
    }

    /// @notice Burns `amount` tokens and give the equivalent ETH back to user
    function returnTokens(uint256 amount) external returns(uint256) {
          uint256 availableTokens = paymentToken.balanceOf(msg.sender);
        require(availableTokens >= amount, "You do not have enough tokens");
        paymentToken.burnFrom(msg.sender, amount);
        uint256 eth = tokensToEth(amount);
      (bool ok,) =  payable(msg.sender).call{value: eth}("");
      require(ok, "failed to send eth");
      return eth;
    }
}