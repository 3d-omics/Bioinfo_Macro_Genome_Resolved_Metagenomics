def get_coverm_assembly_files(wildcards):
    assembly_id = wildcards.assembly_id
    method = wildcards.method
    files = [
        ASSEMBLE_COVERM / f"{assembly_id}.{method}" / f"{sample_id}.{library_id}.tsv.gz"
        for _, sample_id, library_id in ASSEMBLY_SAMPLE_LIBRARY
        if assembly_id == wildcards.assembly_id
    ]
    return files
