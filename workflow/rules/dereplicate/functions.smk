def get_tsvs_for_dereplicate_coverm_genome(wildcards):
    method = wildcards.method
    tsv_files = [
        DEREPLICATE_COVERM / f"genome/{method}/{sample_id}.{library_id}.tsv"
        for sample_id, library_id in SAMPLE_LIBRARY
    ]
    return tsv_files


def get_tsvs_for_dereplicate_coverm_contig(wildcards):
    method = wildcards.method
    tsv_files = [
        DEREPLICATE_COVERM / f"contig/{method}/{sample_id}.{library_id}.tsv"
        for sample_id, library_id in SAMPLE_LIBRARY
    ]
    return tsv_files
