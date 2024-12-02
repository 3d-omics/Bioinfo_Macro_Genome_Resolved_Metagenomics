rule prokaryotes__multiqc:
    input:
        bowtie2=[
            PROK_BOWTIE2
            / f"drep.{secondary_ani}"
            / f"{sample_id}.{library_id}.stats.tsv"
            for sample_id, library_id in SAMPLE_LIBRARY
            for secondary_ani in SECONDARY_ANIS
        ],
        quast=PROK_QUAST,
    output:
        RESULTS / "prokaryotes.html",
        RESULTS / "prokaryotes_data.zip",
    log:
        RESULTS / "prokaryotes.log",
    params:
        extra="--title prokaryotes --dirs --dirs-depth 1 --fullnames --force",
    resources:
        mem_mb=double_ram(8 * 1024),
        runtime=6 * 60,
    wrapper:
        "v5.1.0/bio/multiqc"


rule prokaryotes__multiqc__all:
    input:
        rules.prokaryotes__multiqc.output,
