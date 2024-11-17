rule preprocess__multiqc:
    input:
        reads=[
            PRE_READS / f"{sample_id}.{library_id}_{end}_fastqc.zip"
            for sample_id, library_id in SAMPLE_LIBRARY
            for end in [1, 2]
        ],
        fastp=[
            PRE_FASTP / f"{sample_id}.{library_id}_fastp.json"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
        bowtie2=[
            PRE_BOWTIE2 / f"{host}.{sample_id}.{library_id}.{report}"
            for host in HOST_NAMES
            for report in BAM_REPORTS
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
        clean=[
            PRE_CLEAN / f"{sample_id}.{library_id}_{end}_fastqc.zip"
            for sample_id, library_id in SAMPLE_LIBRARY
            for end in ["1", "2"]
        ],
        nonpareil=[
            PRE_NONPAREIL / f"{sample_id}.{library_id}.json"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
        kraken2=[
            PRE_KRAKEN2 / kraken2_db / f"{sample_id}.{library_id}.report"
            for sample_id, library_id in SAMPLE_LIBRARY
            for kraken2_db in KRAKEN2_DBS
        ],
    output:
        html=RESULTS / "preprocess.html",
        folder=directory(RESULTS / "preprocess_data"),
    log:
        RESULTS / "preprocess.log",
    conda:
        "../../environments/multiqc.yml"
    params:
        outdir=RESULTS,
    resources:
        mem_mb=double_ram(4 * 1024),
        runtime=6 * 60,
    shell:
        """
        multiqc \
            --title preprocess \
            --force \
            --filename preprocess \
            --outdir {params.outdir} \
            --dirs \
            --dirs-depth 1 \
            --fullnames \
            {input} \
        2> {log} 1>&2
        """


rule preprocess__multiqc__all:
    input:
        rules.preprocess__multiqc.output,
