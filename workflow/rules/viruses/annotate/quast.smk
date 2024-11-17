rule viruses__annotate__quast:
    """Run quast over one the dereplicated mags"""
    input:
        MMSEQS / "rep_seq.fa.gz",
    output:
        directory(QUASTV),
    log:
        QUASTV / "quast.log",
    conda:
        "../../../environments/quast.yml"
    threads: 4
    resources:
        mem_mb=8 * 1024,
        runtime=6 *60,
    shell:
        """
        quast \
            --output-dir {output} \
            --threads {threads} \
            {input} \
        2> {log} 1>&2
        """


rule viruses__annotate__quast__all:
    input:
        rules.viruses__annotate__quast.output,
