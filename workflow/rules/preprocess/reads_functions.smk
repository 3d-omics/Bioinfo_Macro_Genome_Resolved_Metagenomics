def get_input_filename(wildcards, forward_or_reverse):
    """Get the initial file"""
    assert forward_or_reverse in ["forward_filename", "reverse_filename"]
    return samples.loc[
        (samples["sample_id"] == wildcards.sample_id)
        & (samples["library_id"] == wildcards.library_id)
    ][forward_or_reverse].values[0]


def get_forward_filename(wildcards):
    """Get the forward read for a given sample and library"""
    return get_input_filename(wildcards, "forward_filename")


def get_reverse_filename(wildcards):
    """Get the reverse read for a given sample and library"""
    return get_input_filename(wildcards, "reverse_filename")
