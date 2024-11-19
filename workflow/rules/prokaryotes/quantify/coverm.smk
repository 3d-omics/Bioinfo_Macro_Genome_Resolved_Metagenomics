use rule coverm__genome as prokaryotes__quantify__coverm__genome with:
    input:
        QUANT_BOWTIE2 / "drep.{secondary_ani}.{sample_id}.{library_id}.bam",
    output:
        temp(
            COVERM
            / "files"
            / "genome.{method}.drep.{secondary_ani}.{sample_id}.{library_id}.tsv.gz"
        ),
    log:
        COVERM
        / "files"
        / "genome.{method}.drep.{secondary_ani}.{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"
    params:
        method=lambda w: w.method,
        extra=params["quantify"]["coverm"]["genome"]["extra"],
        separator=params["quantify"]["coverm"]["genome"]["separator"],


use rule csvkit__csvjoin as prokaryotes__quantify__coverm__genome__csvjoin with:
    input:
        lambda w: [
            COVERM
            / "files"
            / f"genome.{w.method}.drep.{w.secondary_ani}.{sample_id}.{library_id}.tsv.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
    output:
        COVERM / "coverm.genome.{method}.drep.{secondary_ani}.tsv.gz",
    log:
        COVERM / "coverm.genome.{method}.drep.{secondary_ani}.log",
    conda:
        "../../../environments/csvkit.yml"


rule prokaryotes__quantify__coverm__genome__all:
    """Run coverm genome and all methods"""
    input:
        [
            COVERM / f"coverm.genome.{method}.drep.{secondary_ani}.tsv.gz"
            for method in params["quantify"]["coverm"]["genome"]["methods"]
            for secondary_ani in SECONDARY_ANIS
        ],


# coverm contig ----
use rule coverm__contig as prokaryotes__quantify__coverm__contig with:
    input:
        QUANT_BOWTIE2 / "drep.{secondary_ani}.{sample_id}.{library_id}.bam",
    output:
        temp(
            COVERM
            / "files"
            / "contig.{method}.drep.{secondary_ani}.{sample_id}.{library_id}.tsv.gz"
        ),
    log:
        COVERM
        / "files"
        / "contig.{method}.drep.{secondary_ani}.{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"


use rule csvkit__csvjoin as prokaryotes__quantify__coverm__contig__csvjoin with:
    input:
        lambda w: [
            COVERM
            / "files"
            / f"contig.{w.method}.drep.{w.secondary_ani}.{sample_id}.{library_id}.tsv.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
    output:
        COVERM / "coverm.contig.{method}.drep.{secondary_ani}.tsv.gz",
    log:
        COVERM / "coverm.contig.{method}.drep.{secondary_ani}.log",
    conda:
        "../../../environments/csvkit.yml"
    resources:
        mem_mb=32 * 1024,


rule prokaryotes__quantify__coverm__contig__all:
    """Run coverm contig and all methods"""
    input:
        [
            COVERM / f"coverm.contig.{method}.drep.{secondary_ani}.tsv.gz"
            for method in params["quantify"]["coverm"]["contig"]["methods"]
            for secondary_ani in SECONDARY_ANIS
        ],


rule prokaryotes__quantify__coverm__all:
    input:
        rules.prokaryotes__quantify__coverm__genome__all.input,
        rules.prokaryotes__quantify__coverm__contig__all.input,
