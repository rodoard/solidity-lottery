<script>
  import { lotteryClose, lotteryStart, ownerWithdrawFees, playerReturnTokens, playerWithdrawPrize } from "$lib/api";
  import PrimaryButton from "$lib/components/lottery/PrimaryButton.svelte";
  import SecondaryButton from "$lib/components/lottery/SecondaryButton.svelte";
  import UserInfoCard from "$lib/components/lottery/UserInfoCard.svelte";
  import { signMessage } from "@wagmi/core";
  import { DateInput } from "date-picker-svelte";
  import { onMount } from "svelte";
  import { wagmiConfig } from "$lib/wagmi";

  let {
    isOwner,
    isWinner,
    isLotteryClosed,
    betPrice,
    tokenSymbol,
    betFee,
    tokenBalance,
    prizeAmount,
    prizePool,
    isPastLotteryClosingTime,
    ownerFeePool,
    betsClosingTime,
    betsOpen,
    lotteryAddress,
    account,
  } = $props();

  let countdown = $state(""); // Countdown to display

  // Update the countdown if openingTime is known
  const updateCountdown = () => {
    if (!betsOpen || !betsClosingTime) return;
    const now = new Date().getTime();
    const timeDiff = betsClosingTime - now;
    if (timeDiff > 0) {
      const seconds = Math.floor((timeDiff / 1000) % 60);
      const minutes = Math.floor((timeDiff / 1000 / 60) % 60);
      const hours = Math.floor(timeDiff / 1000 / 60 / 60);
      countdown = `Bets will close in ${hours}h ${minutes}m ${seconds}s`;
    } else {
      countdown = "It is passed closing time";
    }
  };

  onMount(() => {
    const interval = setInterval(() => updateCountdown(), 1000);
    return () => clearInterval(interval);
  });

  let future = new Date();
  future.setDate(future.getDate() + 3);
  let closingTime = $state(future);

  let futureTime = new Date();
  futureTime.setTime(futureTime.getTime() + 5 * 60 * 1000);

  // Action handlers
  const startLottery = async () => {
    const signature = await signMessage(wagmiConfig, { message: "start lottery" });
    ({ betsOpen, isLotteryClosed, betsClosingTime, isPastLotteryClosingTime } = await lotteryStart({
      address: account.address,
      closingTime,
      lotteryAddress,
      signature,
    }));
  };
  const closeLottery = async () => {
    const signature = await signMessage(wagmiConfig, { message: "close lottery" });
    await lotteryClose({
      address: account.address,
      lotteryAddress,
      signature,
    });
  };
  const withdrawPrize = async ({ amount }) => {
    const signature = await signMessage(wagmiConfig, { message: "withdraw prize" });
    await playerWithdrawPrize({
      address: account.address,
      lotteryAddress,
      signature,
      amount,
    });
  };

  const returnTokens = async ({ amount }) => {
    const signature = await signMessage(wagmiConfig, { message: "withdraw prize" });
    await playerReturnTokens({
      address: account.address,
      lotteryAddress,
      signature,
      amount,
    });
  };

  const withdrawFees = async ({ amount }) => {
    const signature = await signMessage(wagmiConfig, { message: "withdraw prize" });
    await ownerWithdrawFees({
      address: account.address,
      lotteryAddress,
      signature,
      amount,
    });
  };
</script>

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
          <p class=" font-semibold">You can start a new round immediately by setting an closing time.</p>
          <div class="flex flex-row items-center justify-center gap-8">
            <DateInput
              bind:value={closingTime}
              min={futureTime}
              format="yyyy/MM/dd HH:mm"
              placeholder="2000/31/12 23:59"
            />
            <div>
              <PrimaryButton disabled={closingTime < futureTime} label="Start Lottery" onClick={startLottery} />
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

  <div class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
    <UserInfoCard title="Your Token Balance" value={tokenBalance} unit={tokenSymbol} />
    <UserInfoCard title="Your Prize Pool" value={prizeAmount} unit={tokenSymbol} />
    <UserInfoCard title="Lottery Prize Pool" value={prizePool} unit={tokenSymbol} />

    {#if isOwner}
      <UserInfoCard title="Owner Fee Pool" value={ownerFeePool} unit="ETH" />
    {/if}
  </div>

  <div class="justyif-center mt-6 flex flex-wrap gap-4">
    {#if isOwner}
      {#if ownerFeePool > 0}
        <SecondaryButton label="Withdraw Fees" onClick={withdrawFees} />
      {/if}
    {/if}

    {#if !isLotteryClosed}
      <PrimaryButton label="Place Bet" onClick={() => console.log("Place bet")} />
    {/if}

    {#if prizeAmount > 0}
      <SecondaryButton label="Withdraw Prize" onClick={withdrawPrize} />
    {/if}
  </div>
</div>
