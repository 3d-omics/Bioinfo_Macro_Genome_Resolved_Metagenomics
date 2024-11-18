rule assemble__multiqc:
    input:
        bowtie2=[
            ASSEMBLE_BOWTIE2 / f"{assembly_id}.{sample_id}.{library_id}.{report}"
            for assembly_id, sample_id, library_id in ASSEMBLY_SAMPLE_LIBRARY
            for report in BAM_REPORTS
        ],
        quast=[
            ASSEMBLE_QUAST / f"{assembly_id}"
            for assembly_id, _, _ in ASSEMBLY_SAMPLE_LIBRARY
        ],
        kraken2=[
            ASSEMBLE_KRAKEN2 / kraken2_db / f"{assembly_id}.report"
            for kraken2_db in features["databases"]["kraken2"]
            for assembly_id in ASSEMBLIES
        ],
    output:
        html=RESULTS / "assemble.html",
        folder=directory(RESULTS / "assemble_data"),
    log:
        RESULTS / "assemble.log",
    conda:
        "../../environments/multiqc.yml"
    params:
        outdir=RESULTS,
    resources:
        mem_mb=double_ram(8 * 1024),
        runtime=6 * 60,
    shell:
        """
        multiqc \
            --title assemble \
            --force \
            --filename assemble \
            --outdir {params.outdir} \
            --dirs \
            --dirs-depth 1 \
            --fullnames \
            {input} \
        2> {log} 1>&2
        """


rule assemble__multiqc__all:
    input:
        rules.assemble__multiqc.output,
