use rule coverm__contig as assemble__coverm__contig with:
    input:
        ASMB_BOWTIE2 / "{assembly_id}.{sample_id}.{library_id}.bam",
    output:
        temp(
            ASMB_COVERM
            / "files"
            / "{method}.{assembly_id}.{sample_id}.{library_id}.tsv.gz"
        ),
    log:
        ASMB_COVERM / "files" / "{method}.{assembly_id}.{sample_id}.{library_id}.log",
    conda:
        "../../environments/coverm.yml"
    params:
        method=lambda w: w.method,


use rule csvkit__csvjoin as assemble__coverm__csvjoin with:
    input:
        lambda w: [
            ASMB_COVERM
            / "files"
            / f"{w.method}.{w.assembly_id}.{sample_id}.{library_id}.tsv.gz"
            for assembly_id, sample_id, library_id in ASSEMBLY_SAMPLE_LIBRARY
            if assembly_id == w.assembly_id
        ],
    output:
        ASMB_COVERM / "coverm.{method}.{assembly_id}.tsv.gz",
    log:
        ASMB_COVERM / "coverm.{method}.{assembly_id}.log",
    conda:
        "../../environments/csvkit.yml"


rule assemble__coverm__all:
    input:
        [
            ASMB_COVERM / f"coverm.{method}.{assembly_id}.tsv.gz"
            for assembly_id in ASSEMBLIES
            for method in params["quantify"]["coverm"]["contig"]["methods"]
        ],
