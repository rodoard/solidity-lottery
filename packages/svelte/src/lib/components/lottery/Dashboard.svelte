<script lang="ts">
  import PrimaryButton from "$lib/components/lottery/PrimaryButton.svelte";
  import SecondaryButton from "$lib/components/lottery/SecondaryButton.svelte";
  import UserInfoCard from "$lib/components/lottery/UserInfoCard.svelte";
  import { signMessage, signTypedData, verifyTypedData } from "@wagmi/core";
  import { onMount } from "svelte";
  import { wagmiConfig } from "$lib/wagmi";
  import { createScaffoldReadContract } from "$lib/runes/scaffoldReadContract.svelte";
  import { createScaffoldWriteContract } from "$lib/runes/scaffoldWriteContract.svelte";
  import { formatEther, hashTypedData, parseEther, parseSignature } from "viem";
  import { createDeployedContractInfo } from "$lib/runes/deployedContractInfo.svelte";
  import { createTargetNetwork } from "$lib/runes/targetNetwork.svelte";
  import { createReadContract } from "@byteatatime/wagmi-svelte";
  import {
    type LotteryInfo,
  } from "$lib/api";

  const MAXUINT256 =
  115792089237316195423570985008687907853269984665640564039457584007913129639935n;

  let isLoading = $state(false);
  let {
    isOwner,
    isWinner,
    isLotteryClosed,
    currentTimeStamp,
    betPrice,
    tokenSymbol,
    betFee,
    tokenBalance,
    tokenName,
    prizeAmount,
    prizePool,
    isPastLotteryClosingTime,
    ownerFeePool,
    betsClosingTime,
    betsOpen,
    nonce,
    tokenAddress,
    lotteryAddress,
    account,
    purchaseRatio,
    maxBets,
    lotteryName,
  } = $props();

  let countdown = $state(""); // Countdown to display
  let minBets = $derived(Math.min(Number(maxBets), 1));
  let bet = $state(0);
  let numTokens = $state(0);
  let secondsFromNow = $state(0);
  // Update the countdown if openingTime is known
  const updateCountdown = () => {
    if (!betsOpen || !betsClosingTime) return;
    const now = currentTimeStamp;
    const timeDiff = Number(betsClosingTime - currentTimeStamp);
    if (timeDiff > 0) {
      const seconds = Math.floor(timeDiff % 60);
      const minutes = Math.floor((timeDiff / 60) % 60);
      const hours = Math.floor(timeDiff / 60 / 60);
      countdown = `Bets will close in ${hours}h ${minutes}m ${seconds}s`;
    } else {
      countdown = "It is passed closing time";
    }
  };

  const { data: deployedContract } = $derived.by(createDeployedContractInfo(lotteryName));
  const targetNetwork = $derived.by(createTargetNetwork());
  const functionName = "sessionInfo";
  let info: LotteryInfo = $state({});
  let contractRead = $derived.by(
    createReadContract(() => ({
      account: account.address,
      chainId: targetNetwork.id,
      functionName,
      address: deployedContract?.address,
      abi: deployedContract?.abi,
      args: [],
      query: {
        retry: false,
      },
    })),
  );
  function fromReadData(data) {
    let {
    betPrice, betFee, tokenBalance,
    ownerPool, prizeAmount, prizePool
   } = data 
   const result = {
    betPrice, betFee, tokenBalance, prizeAmount, ownerFeePool:ownerPool, prizePool
   }
   return {
    ...data,
    ...Object.entries(result).reduce((acc, [k,v])=> {
      acc[k]=formatEther(v)
      return acc
    }, {})
   }
  }
  $effect(() => {
    if (!contractRead.isPending) {
      info = fromReadData(contractRead.data)
      isLoading = false;
    }
  });
  $effect(() => {
    ({
      isOwner,
      currentTimeStamp,
      isWinner,
      isLotteryClosed,
      betPrice,
      tokenSymbol,
      tokenName,
      nonce,
      betFee,
      tokenAddress,
      tokenBalance,
      prizeAmount,
      prizePool,
      isPastLotteryClosingTime,
      ownerFeePool,
      betsClosingTime,
      betsOpen,
      purchaseRatio,
      maxBets,
    } = info);
    updateCountdown();
  });

  // Action handlers
  const startLottery = async () => {
    const closingTime = Math.floor(Date.now() / 1000) + secondsFromNow;
    await writeContractAsync(
      {
        functionName: "startLottery",
        args: [BigInt(closingTime)],
      },
      {
        onBlockConfirmation: txnReceipt => {
          console.log("📦 Transaction blockHash", txnReceipt.blockHash);
        },
      },
    );
    contractRead?.refetch();
  };

  const closeLottery = async () => {
    await writeContractAsync(
      {
        functionName: "closeLottery",
      },
      {
        onBlockConfirmation: txnReceipt => {
          console.log("📦 Transaction blockHash", txnReceipt.blockHash);
        },
      },
    );
    contractRead?.refetch();
  };
  const withdrawPrize = async () => {
    const amount = withdraw
    await writeContractAsync(
      {
        functionName: "prizeWithdraw",
        args:[parseEther(amount.toString())]
      },
      {
        onBlockConfirmation: txnReceipt => {
          console.log("📦 Transaction blockHash", txnReceipt.blockHash);
        },
      })
    contractRead?.refetch();
  };

  const withdrawFees = async () => {
    const amount = fees
    await writeContractAsync(
      {
        functionName: "ownerWithdraw",
        args:[parseEther(amount.toString())]
      },
      {
        onBlockConfirmation: txnReceipt => {
          console.log("📦 Transaction blockHash", txnReceipt.blockHash);
        },
      })
    contractRead?.refetch();
  };

  const returnTokens = async () => {
    const amount = burn
    const value = parseEther(amount.toString())
    const deadline = Math.floor(Date.now() / 1000) + 3600; 
   await permit({
      value, deadline
    })
    await writeContractAsync(
      {
        functionName: "returnTokens",
        args:[value]
      },
      {
        onBlockConfirmation: txnReceipt => {
          console.log("📦 Transaction blockHash", txnReceipt.blockHash);
        },
      })
    contractRead?.refetch();
  };

const types = {
  EIP712Domain: [
    { name: "name", type: "string" },
    { name: "version", type: "string" },
    { name: "chainId", type: "uint256" },
    { name: "verifyingContract", type: "address" },
  ],
  Permit: [
    { name: "owner", type: "address" },
    { name: "spender", type: "address" },
    { name: "value", type: "uint256" },
    { name: "nonce", type: "uint256" },
    { name: "deadline", type: "uint256" },
  ],
};
let burn = $state(0)
let withdraw = $state(0)
let fees = $state(0)

// Define parameters
const owner = account.address;
const spender = lotteryAddress;

  const permit = async ({value, deadline})=> {
    const domain = {
  name: tokenName,
  version: "1",
  chainId: targetNetwork.id,
  verifyingContract: tokenAddress
    }
 const message =  {
    owner,
    spender,
    value:value.toString(),
    nonce,
    deadline,
  }
const signature = await signTypedData(wagmiConfig, {
  domain,
  types,
  primaryType: "Permit",
  message
});
  
const { v, r, s } = parseSignature(signature);

try {
      await writeContractAsync(
        {
          functionName: "permitBets",
          args:[
            owner,
  spender,
  value,
  deadline,
  v,
  r,
  s
          ]
        },
        {
          onBlockConfirmation: txnReceipt => {
            console.log("📦 Transaction blockHash", txnReceipt.blockHash);
          },
        },
      );
    } catch (e) {
      console.error(e);
    }
}

  let { writeContractAsync} = $derived.by(createScaffoldWriteContract(lotteryName));

  const buyTokens = async () => {
    try {
      await writeContractAsync(
        {
          functionName: "purchaseTokens",
          value: parseEther(numTokens.toString()) / purchaseRatio,
        },
        {
          onBlockConfirmation: txnReceipt => {
            console.log("📦 Transaction blockHash", txnReceipt.blockHash);
          },
        },
      );
      contractRead?.refetch();
    } catch (e) {
      console.error(e);
    }
  };
  const placeBet = async () => {
    const requiredTokens = Math.ceil(Number(betFee) + Number(betPrice)) * bet
    const value = parseEther(requiredTokens.toString())
    const deadline = Math.floor(Date.now() / 1000) + 3600; 
   await permit({
      value, deadline
    })
    try {
      await writeContractAsync(
        {
          functionName: "betMany",
          args: [bet],
        },
        {
          onBlockConfirmation: txnReceipt => {
            console.log("📦 Transaction blockHash", txnReceipt.blockHash);
          },
        },
      );
    } catch (e) {
      console.error(e);
    } finally {
      contractRead?.refetch();
    }
  };
</script>

{#if isLoading}
  <button class="btn">
    <span class="loading loading-spinner"></span>
    Loading lottery contract
  </button>
{:else}
  <div class="p-6">
    <!-- Welcome Section -->
    <div class="bg-primary text-primary-content mb-6 rounded-lg p-6 text-center shadow-md">
      <h1 class="text-2xl font-bold">Welcome to the Lottery!</h1>
      <p class="mt-2 text-lg">Play the lottery and stand a chance to win big prizes.</p>
      <div class="grid grid-cols-2 gap-4">
        <div>
          <span class="font-semibold">Bet Price:</span>
          {betPrice}
          {tokenSymbol}
        </div>
        <div>
          <span class="font-semibold">Bet Fee:</span>
          {betFee}
          {tokenSymbol}.
        </div>
      </div>
    </div>

    <!-- Winner Message -->
    {#if isLotteryClosed && isWinner}
      <div class="bg-success text-success-content mb-6 rounded-lg p-4 shadow-md">
        <h2 class="text-xl font-bold">🎉 Congratulations!</h2>
        <p>You won this lottery round and can now withdraw your prize!</p>
      </div>
    {/if}

    <!-- Lottery Status Section -->
    {#if isLotteryClosed}
      <div class="bg-warning text-warning-content mb-6 rounded-lg p-4 shadow-md">
        {#if isOwner}
          <p class="font-bold">The lottery is currently closed.</p>
          <div class="flex flex-col justify-center">
            <p class=" font-semibold">You can start a new round immediately by setting duration in seconds.</p>
            <div class="flex flex-row items-center justify-center gap-8">
              <input type="number" bind:value={secondsFromNow} class="input input-bordered" />
              <div>
                <PrimaryButton disabled={secondsFromNow == 0} label="Start Lottery" onClick={startLottery} />
              </div>
            </div>
          </div>
        {:else}
          <p class="font-bold">Bets are not currently open.</p>
          <p class="mt-2">Please check back later for the next round.</p>
        {/if}
      </div>
    {:else}
      <div class="bg-warning text-warning-content mb-6 rounded-lg p-4 shadow-md">
        <div class="flex flex-col justify-center">
          <p class="font-bold">{countdown}</p>
          {#if isPastLotteryClosingTime}
            <PrimaryButton label="Close Lottery" onClick={closeLottery} />
          {/if}
        </div>
      </div>
    {/if}

    <div class="rid grid auto-cols-max grid-flow-col gap-2">
      <UserInfoCard title="Your Token Balance" value={tokenBalance} unit={tokenSymbol} />
      <UserInfoCard title="Your Prize Pool" value={prizeAmount} unit={tokenSymbol} />
      <UserInfoCard title="Lottery Prize Pool" value={prizePool} unit={tokenSymbol} />

      {#if isOwner}
        <UserInfoCard title="Owner Fee Pool" value={ownerFeePool} unit={tokenSymbol} />
      {/if}
    </div>

    <div class="mt-6 flex flex-wrap justify-center gap-4">
      <div class="form-control">
        <p class="label-text text-center">Num Tokens</p>
        <label class="input-group">
          <input type="number" bind:value={numTokens} class="input input-bordered" />
        </label>
        <PrimaryButton disabled={Number(numTokens) == 0} label="Buy Tokens" onClick={buyTokens} />
      </div>
      {#if tokenBalance > 0} 
      <div class="form-control">
        <p class="label-text text-center">Max: {tokenBalance}</p>
        <label class="input-group">
          <input
            type="number"
            bind:value={burn}
            min={0}
            max={tokenBalance}
            class="input input-bordered w-full"
          />
        </label>
        <PrimaryButton disabled={burn == 0} label="Return Tokens" onClick={returnTokens} />
      </div>
      {/if}
      {#if isOwner}
        {#if ownerFeePool > 0}
        <div class="form-control">
          <p class="label-text text-center">Max: {ownerFeePool}</p>
          <label class="input-group">
            <input
              type="number"
              bind:value={fees}
              min={0}
              max={ownerFeePool}
              class="input input-bordered w-full"
            />
          </label>
          <SecondaryButton disabled={fees==0} label="Withdraw Fees" onClick={withdrawFees} />
       </div>
        {/if}
      {/if}

      {#if !isLotteryClosed}
        <div class="form-control">
          <p class="label-text text-center">Max: {maxBets}</p>
          <label class="input-group">
            <input
              type="number"
              bind:value={bet}
              min={minBets}
              max={maxBets}
              placeholder={minBets.toString()}
              class="input input-bordered"
            />
          </label>
          <PrimaryButton disabled={bet == 0} label="Place Bet" onClick={placeBet} />
        </div>
      {/if}

      {#if prizeAmount > 0}
      <div class="form-control">
        <p class="label-text text-center">Max: {prizeAmount}</p>
        <label class="input-group">
          <input
            type="number"
            bind:value={withdraw}
            min={0}
            max={prizeAmount}
            class="input input-bordered w-full"
          />
        </label>
        <SecondaryButton  disabled={withdraw==0}  label="Withdraw Prize" onClick={withdrawPrize} />
       </div>
        {/if}
    </div>
  </div>
{/if}
