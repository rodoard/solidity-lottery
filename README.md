# Solidity Lottery Full Stack

A dApp based on scaffold-eth-svelte that implements a lottery that requires
purchasing lottery tokens using eth
to place bets.  Winner is a randomly
player who has placed bets in the current lottery session.  Winner
is awarded lottery tokens.  Lottery
owner collects fees on every bet
and can get the equivalent eth amount
when the lottery closes.  Anyone
can close lottery after elapsed time.
Only owner can start the lottery immediately by specifying a duration 
in seconds.  Players can burn tokens
and get back eth.  Players can claim
their prize to increase their token balance. 

## Getting Started

1. Clone this repo

```
git clone https://github.com/rodoard/solidity-fullstack.git
cd solidity-fullstack
yarn
```

2. Run a local chain

```
yarn chain
```

3. On a second terminal, deploy the example contract

```
yarn deploy
```

4. Start the frontend

```
yarn start
```

Your app should now be running on `http://localhost:3000`.

## Documentation

![Lottery Start!]("./lottery-start.png")

![Lottery Home!]("./lottery-home.png")

![Lottery Congrats!]("./lottery-congrats.png")

