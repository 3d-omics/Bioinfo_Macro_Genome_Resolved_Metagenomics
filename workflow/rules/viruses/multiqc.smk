rule viruses__multiqc:
    input:
        bowtie2=[
            VBOWTIE2 / f"{sample_id}.{library_id}.{report}"
            for sample_id, library_id in SAMPLE_LIBRARY
            for report in BAM_REPORTS
        ],
        quast=QUASTV,
    output:
        RESULTS / "viruses.html",
        RESULTS / "viruses_data.zip",
    log:
        RESULTS / "viruses.log",
    params:
        extra="--title viruses --dirs --dirs-depth 1 --fullnames --force",
    wrapper:
        "v5.1.0/bio/multiqc"


rule viruses__multiqc__all:
    input:
        rules.viruses__multiqc.output,
