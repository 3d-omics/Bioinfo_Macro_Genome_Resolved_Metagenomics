# coverm genome ----
use rule coverm__genome as viruses__quantify__coverm__genome with:
    input:
        VIR_BOWTIE2 / "{sample_id}.{library_id}.bam",
    output:
        temp(VIR_COVERM / "files" / "genome.{method}.{sample_id}.{library_id}.tsv.gz"),
    log:
        VIR_COVERM / "files" / "genome.{method}.{sample_id}.{library_id}.log",
    conda:
        "../../../environments/coverm.yml"
    params:
        method=lambda w: w.method,
        extra=params["quantify"]["coverm"]["genome"]["extra"],
        separator=params["quantify"]["coverm"]["genome"]["separator"],


rule viruses__quantify__coverm__genome__join:
    input:
        lambda w: [
            VIR_COVERM / "files" / f"genome.{w.method}.{sample_id}.{library_id}.tsv.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
    output:
        VIR_COVERM / "coverm.genome.{method}.tsv.gz",
    log:
        VIR_COVERM / "coverm.genome.{method}.log",
    params:
        subcommand="join",
    wrapper:
        "v5.2.1/utils/csvtk"


rule viruses__quantify__coverm__genome__all:
    """Run coverm genome and all methods"""
    input:
        [
            VIR_COVERM / f"coverm.genome.{method}.tsv.gz"
            for method in ["count", "covered_bases"]
        ],


# coverm contig ----
# use rule coverm__contig as viruses__quantify__coverm__contig with:
#     input:
#         VIR_BOWTIE2 / "{sample_id}.{library_id}.bam",
#     output:
#         temp(VIR_COVERM / "files" / "contig.{method}.{sample_id}.{library_id}.tsv.gz"),
#     log:
#         VIR_COVERM / "files" / "contig.{method}.{sample_id}.{library_id}.log",
#     conda:
#         "../../../environments/coverm.yml"
#     params:
#         method=lambda w: w.method,


# rule viruses__quantify__coverm__contig__join:
#     input:
#         lambda w: [
#             VIR_COVERM / "files" / f"contig.{w.method}.{sample_id}.{library_id}.tsv.gz"
#             for sample_id, library_id in SAMPLE_LIBRARY
#         ],
#     output:
#         VIR_COVERM / "coverm.contig.{method}.tsv.gz",
#     log:
#         VIR_COVERM / "coverm.contig.{method}.log",
#     params:
#         subcommand="join",
#     wrapper:
#         "v5.2.1/utils/csvtk"


# rule viruses__quantify__coverm__contig__all:
#     """Run coverm contig and all methods"""
#     input:
#         [
#             VIR_COVERM / f"coverm.contig.{method}.tsv.gz"
#             for method in params["quantify"]["coverm"]["contig"]["methods"]
#         ],


rule viruses__quantify__coverm__all:
    input:
        # rules.viruses__quantify__coverm__contig__all.input,
        rules.viruses__quantify__coverm__genome__all.input,
