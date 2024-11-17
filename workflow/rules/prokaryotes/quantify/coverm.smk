include: "coverm_functions.smk"


use rule coverm__genome as prokaryotes__quantify__coverm__genome with:
    input:
        QUANT_BOWTIE2 / "drep.{secondary_ani}" / "{sample_id}.{library_id}.bam",
    output:
        COVERM
        / "genome"
        / "{method}"
        / "drep.{secondary_ani}"
        / "{sample_id}.{library_id}.tsv.gz",
    log:
        COVERM
        / "genome"
        / "{method}"
        / "drep.{secondary_ani}"
        / "{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"
    params:
        method=lambda w: w.method,
        extra=params["quantify"]["coverm"]["genome"]["extra"],
        separator=params["quantify"]["coverm"]["genome"]["separator"],


use rule csvkit__aggregate as prokaryotes__quantify__coverm__genome__aggregate with:
    input:
        get_tsvs_for_dereplicate_coverm_genome,
    output:
        COVERM / "genome.{method}.drep.{secondary_ani}.tsv.gz",
    log:
        COVERM / "genome.{method}.drep.{secondary_ani}.log",
    conda:
        "../../../environments/csvkit.yml"


rule prokaryotes__quantify__coverm__genome__all:
    """Run coverm genome and all methods"""
    input:
        [
            COVERM / f"genome.{method}.drep.{secondary_ani}.tsv.gz"
            for method in params["quantify"]["coverm"]["genome"]["methods"]
            for secondary_ani in SECONDARY_ANIS
        ],


# coverm contig ----
use rule coverm__contig as prokaryotes__quantify__coverm__contig with:
    input:
        QUANT_BOWTIE2 / "drep.{secondary_ani}" / "{sample_id}.{library_id}.bam",
    output:
        COVERM
        / "contig"
        / "{method}"
        / "drep.{secondary_ani}"
        / "{sample_id}.{library_id}.tsv.gz",
    log:
        COVERM
        / "contig"
        / "{method}"
        / "drep.{secondary_ani}"
        / "{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"


use rule csvkit__aggregate as prokaryotes__quantify__coverm__contig__aggregate with:
    input:
        get_tsvs_for_dereplicate_coverm_contig,
    output:
        COVERM / "contig.{method}.drep.{secondary_ani}.tsv.gz",
    log:
        COVERM / "contig.{method}.drep.{secondary_ani}log",
    conda:
        "../../../environments/csvkit.yml"


rule prokaryotes__quantify__coverm__contig__all:
    """Run coverm contig and all methods"""
    input:
        [
            COVERM / f"contig.{method}.drep.{secondary_ani}.tsv.gz"
            for method in params["quantify"]["coverm"]["contig"]["methods"]
            for secondary_ani in SECONDARY_ANIS
        ],


rule prokaryotes__quantify__coverm__all:
    input:
        rules.prokaryotes__quantify__coverm__genome__all.input,
        rules.prokaryotes__quantify__coverm__contig__all.input,
