<script>
  let { label, onClick, disabled } = $props();
</script>

<button {disabled} class="btn btn-primary" on:click={onClick}>
  {label}
</button>
