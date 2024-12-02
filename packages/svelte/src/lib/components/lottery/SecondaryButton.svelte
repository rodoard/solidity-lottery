<script>
  let { label, onClick, disabled } = $props();
</script>

<button {disabled} class="btn btn-secondary" on:click={onClick}>
  {label}
</button>
