rule prokaryotes__multiqc:
    input:
        bowtie2=[
            QUANT_BOWTIE2 / f"drep.{secondary_ani}.{sample_id}.{library_id}.stats.tsv"
            for sample_id, library_id in SAMPLE_LIBRARY
            for secondary_ani in SECONDARY_ANIS
        ],
        quast=QUAST,
    output:
        html=RESULTS / "prokaryotes.html",
        folder=directory(RESULTS / "prokaryotes_data"),
    log:
        RESULTS / "prokaryotes.log",
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
            --title prokaryotes \
            --force \
            --filename prokaryotes \
            --outdir {params.outdir} \
            --dirs \
            --dirs-depth 1 \
            --fullnames \
            {input} \
        2> {log} 1>&2

        gzip
            --best \
            --verbose \
            {output.folder}/*.txt \
            {output.folder}/*.json \
        2>> {log} 1>&2
        """


rule prokaryotes__multiqc__all:
    input:
        rules.prokaryotes__multiqc.output,
