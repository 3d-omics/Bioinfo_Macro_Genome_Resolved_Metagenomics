include: "coverm_functions.smk"


use rule coverm__contig as assemble__coverm__contig with:
    input:
        ASSEMBLE_BOWTIE2 / "{assembly_id}.{sample_id}.{library_id}.bam",
    output:
        ASSEMBLE_COVERM / "{assembly_id}.{method}" / "{sample_id}.{library_id}.tsv.gz",
    log:
        ASSEMBLE_COVERM / "{assembly_id}.{method}" / "{sample_id}.{library_id}.log",
    conda:
        "../../environments/coverm.yml"
    params:
        method=lambda w: w.method,


use rule csvkit__aggregate as assemble__coverm__aggregate with:
    input:
        get_coverm_assembly_files,
    output:
        ASSEMBLE_COVERM / "coverm.{assembly_id}.{method}.tsv.gz",
    log:
        ASSEMBLE_COVERM / "coverm.{assembly_id}.{method}.log",
    conda:
        "../../environments/csvkit.yml"


rule assemble__coverm__all:
    input:
        [
            ASSEMBLE_COVERM / f"coverm.{assembly_id}.{method}.tsv.gz"
            for assembly_id in ASSEMBLIES
            for method in params["quantify"]["coverm"]["contig"]["methods"]
        ],
