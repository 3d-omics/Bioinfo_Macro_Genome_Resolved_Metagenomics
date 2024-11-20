rule viruses__annotate__checkv:
    input:
        fasta=VIR_MMSEQS / "rep_seq.fa.gz",
        database=features["databases"]["checkv"],
    output:
        complete_genomes=VIR_CHECKV / "complete_genomes.tsv",
        completeness=VIR_CHECKV / "completeness.tsv",
        contamination=VIR_CHECKV / "contamination.tsv",
        proviruses=VIR_CHECKV / "proviruses.fna",
        summary=VIR_CHECKV / "quality_summary.tsv",
        viruses=VIR_CHECKV / "viruses.fna",
    log:
        VIR_CHECKV / "checkv.log",
    conda:
        "../../../environments/checkv.yml"
    params:
        workdir=VIR_CHECKV,
    threads: 24
    resources:
        mem_mb=8 * 1024,
        runtime=24 * 60,
    shell:
        """
        checkv end_to_end \
            -d {input.database} \
            -t {threads} \
            --restart \
            {input.fasta} \
            {params.workdir} \
        2> {log} 1>&2
        """


rule viruses__annotate__checkv__all:
    input:
        rules.viruses__annotate__checkv.output,
