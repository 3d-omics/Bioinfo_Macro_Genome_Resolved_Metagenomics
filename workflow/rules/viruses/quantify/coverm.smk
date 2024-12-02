# coverm genome ----
use rule coverm__genome as viruses__quantify__coverm__genome with:
    input:
        VIR_BOWTIE2 / "rep_seq" / "{sample_id}.{library_id}.bam",
    output:
        temp(VIR_COVERM / "genome" / "{method}.rep_seq.{sample_id}.{library_id}.tsv.gz"),
    log:
        VIR_COVERM / "genome" / "{method}.{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"
    params:
        method=lambda w: w.method,
        extra=params["quantify"]["coverm"]["genome"]["extra"],
        separator=params["quantify"]["coverm"]["genome"]["separator"],


rule viruses__quantify__coverm__genome__join:
    input:
        lambda w: [
            VIR_COVERM / "genome" / f"{w.method}.rep_seq.{sample_id}.{library_id}.tsv.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
    output:
        VIR_COVERM / "genome.{method}.rep_seq.tsv.gz",
    log:
        VIR_COVERM / "genome.{method}.rep_seq.log",
    params:
        subcommand="join",
        extra="--left-join --tabs --out-tabs",
    wrapper:
        "v5.2.1/utils/csvtk"


rule viruses__quantify__coverm__genome__all:
    """Run coverm genome and all methods"""
    input:
        [
            VIR_COVERM / f"genome.{method}.rep_seq.tsv.gz"
            for method in ["count", "covered_bases"]
        ],


rule viruses__quantify__coverm__all:
    input:
        rules.viruses__quantify__coverm__genome__all.input,
