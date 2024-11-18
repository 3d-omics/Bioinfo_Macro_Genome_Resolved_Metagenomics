def get_adapter(wildcards, forward_or_reverse):
    """Get forward or reverse adapter"""
    assert forward_or_reverse in ["forward_adapter", "reverse_adapter"]
    return samples[
        (samples["sample_id"] == wildcards.sample_id)
        & (samples["library_id"] == wildcards.library_id)
    ][forward_or_reverse].tolist()[0]


def get_forward_adapter(wildcards):
    """Get forward adapter for a sample and library."""
    return get_adapter(wildcards, "forward_adapter")


def get_reverse_adapter(wildcards):
    """Get reverse adapter for a sample and library."""
    return get_adapter(wildcards, "reverse_adapter")


def compose_adapters(wildcards):
    """Compose the forward and reverse adapter line for fastp"""
    forward = get_forward_adapter(wildcards)
    reverse = get_reverse_adapter(wildcards)
    return f"--adapter_sequence {forward} --adapter_sequence_r2 {reverse}"
