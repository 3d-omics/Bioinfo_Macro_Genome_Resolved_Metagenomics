def get_attempt(wildcards, attempt):
    """Get the number of attempt in resources"""
    return attempt

def double_ram(initial_memory):
    """Double the memory for each attempt"""
    return lambda wildcards, attempt: initial_memory * 2 ** (attempt - 1)