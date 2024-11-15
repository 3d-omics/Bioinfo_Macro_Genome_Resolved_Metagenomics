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
    params:
        method=lambda w: w.method,
        min_covered_fraction=params["quantify"]["coverm"]["genome"][
            "min_covered_fraction"
        ],
        separator=params["quantify"]["coverm"]["genome"]["separator"],
    conda:
        "../../../environments/coverm.yml"


rule prokaryotes__quantify__coverm__genome__aggregate:
    """Run coverm genome and a single method"""
    input:
        get_tsvs_for_dereplicate_coverm_genome,
    output:
        COVERM / "genome.{method}.drep.{secondary_ani}.tsv.gz",
    log:
        COVERM / "genome.{method}.drep.{secondary_ani}.log",
    conda:
        "../../../environments/r.yml"
    params:
        input_dir=lambda w: COVERM / "genome" / w.method / f"drep.{w.secondary_ani}",
    shell:
        """
        Rscript --vanilla workflow/scripts/aggregate_coverm.R \
            --input-folder {params.input_dir} \
            --output-file {output} \
        2> {log} 1>&2
        """


rule prokaryotes__quantify__coverm__genome__all:
    """Run coverm genome and all methods"""
    input:
        [
            COVERM / f"genome.{method}.drep.{secondary_ani}.tsv.gz"
            for method in params["quantify"]["coverm"]["genome"]["methods"]
            for secondary_ani in SECONDARY_ANIS
        ],


# coverm contig ----
rule prokaryotes__quantify__coverm__contig:
    """Run coverm contig for one library and one mag catalogue"""
    input:
        QUANT_BOWTIE2 / "drep.{secondary_ani}" / "{sample_id}.{library_id}.bam",
    output:
        COVERM
        / "contig"
        / "{method}"
        / "drep.{secondary_ani}"
        / "{sample_id}.{library_id}.tsv.gz",
    conda:
        "../../../environments/coverm.yml"
    log:
        COVERM
        / "contig"
        / "{method}"
        / "drep.{secondary_ani}"
        / "{sample_id}.{library_id}.log",
    params:
        method=lambda w: w.method,
    shell:
        """
        ( coverm contig \
            --bam-files {input} \
            --methods {params.method} \
            --proper-pairs-only \
        | gzip --best \
        > {output} \
        ) 2> {log}
        """


rule prokaryotes__quantify__coverm__contig__aggregate:
    """Run coverm contig and a single method"""
    input:
        get_tsvs_for_dereplicate_coverm_contig,
    output:
        tsv=COVERM / "contig.{method}.drep.{secondary_ani}.tsv.gz",
    log:
        COVERM / "contig.{method}.drep.{secondary_ani}log",
    conda:
        "../../../environments/r.yml"
    params:
        input_dir=lambda w: COVERM / "contig" / w.method / f"drep{w.secondary_ani}",
    shell:
        """
        Rscript --vanilla workflow/scripts/aggregate_coverm.R \
            --input-folder {params.input_dir} \
            --output-file {output} \
        2> {log} 1>&2
        """


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
