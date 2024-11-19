# coverm genome ----
use rule coverm__genome as viruses__quantify__coverm__genome with:
    input:
        VBOWTIE2 / "{sample_id}.{library_id}.bam",
    output:
        temp(VCOVERM / "files" / "genome.{method}.{sample_id}.{library_id}.tsv.gz"),
    log:
        VCOVERM / "files" / "genome.{method}.{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"
    params:
        method=lambda w: w.method,
        extra=params["quantify"]["coverm"]["genome"]["extra"],
        separator=params["quantify"]["coverm"]["genome"]["separator"],


use rule csvkit__csvjoin as viruses__quantify__coverm__genome_aggregate with:
    input:
        lambda w: [
            VCOVERM / "files" / f"genome.{w.method}.{sample_id}.{library_id}.tsv.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
    output:
        VCOVERM / "coverm.genome.{method}.tsv.gz",
    log:
        VCOVERM / "coverm.genome.{method}.log",
    conda:
        "../../../environments/csvkit.yml"


rule viruses__quantify__coverm__genome__all:
    """Run coverm genome and all methods"""
    input:
        [
            VCOVERM / f"coverm.genome.{method}.tsv.gz"
            for method in params["quantify"]["coverm"]["genome"]["methods"]
        ],


# coverm contig ----
use rule coverm__contig as viruses__quantify__coverm__contig with:
    input:
        VBOWTIE2 / "{sample_id}.{library_id}.bam",
    output:
        temp(VCOVERM / "files" / "contig.{method}.{sample_id}.{library_id}.tsv.gz"),
    log:
        VCOVERM / "files" / "contig.{method}.{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"
    params:
        method=lambda w: w.method,


use rule csvkit__csvjoin as viruses__quantify__coverm__contig_aggregate with:
    input:
        lambda w: [
            VCOVERM / "files" / f"contig.{w.method}.{sample_id}.{library_id}.tsv.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
    output:
        VCOVERM / "coverm.contig.{method}.tsv.gz",
    log:
        VCOVERM / "coverm.contig.{method}.log",
    conda:
        "../../../environments/csvkit.yml"


rule viruses__quantify__coverm__contig__all:
    """Run coverm contig and all methods"""
    input:
        [
            VCOVERM / f"coverm.contig.{method}.tsv.gz"
            for method in params["quantify"]["coverm"]["contig"]["methods"]
        ],


rule viruses__quantify__coverm__all:
    input:
        rules.viruses__quantify__coverm__contig__all.input,
        rules.viruses__quantify__coverm__genome__all.input,
