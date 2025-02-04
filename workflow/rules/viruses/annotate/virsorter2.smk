rule viruses__annotate__virsorter2:
    input:
        fna=VIR_GENOMADA / "rep_seq_virus.fna.gz",
        database=features["databases"]["virsorter2"],
    output:
        viruses_boundary=VIR_VIRSORTER2 / "final-viral-boundary.tsv.gz",
        combined=VIR_VIRSORTER2 / "final-viral-combined.fa.gz",
        score=VIR_VIRSORTER2 / "final-viral-score.tsv.gz",
        fa=VIR_VIRSORTER2 / "final-viral-combined-for-dramv.fa.gz",
        tsv=VIR_VIRSORTER2 / "viral-affi-contigs-for-dramv.tab.gz",
    log:
        VIR_VIRSORTER2 / "virsorter2.log",
    conda:
        "../../../environments/virsorter2.yml"
    params:
        workdir=VIR_VIRSORTER2,
    shadow:
        "minimal"
    threads: 24
    resources:
        mem_mb=8 * 1024,
        runtime=60,
    shell:
        """
        virsorter run \
            --working-dir {params.workdir} \
            --jobs {threads} \
            --prep-for-dramv \
            --tmpdir {params.workdir}/tmp \
            --rm-tmpdir \
            --verbose \
            --seqfile {input.fna} \
            --db-dir {input.database} \
        2> {log} 1>&2

        mv \
            {params.workdir}/for-dramv/viral-affi-contigs-for-dramv.tab \
            {params.workdir}/for-dramv/final-viral-combined-for-dramv.fa \
            {params.workdir}/ \
        2>> {log} 1>&2

        bgzip \
            --threads {threads} \
            {params.workdir}/final-viral-boundary.tsv \
            {params.workdir}/final-viral-combined.fa \
            {params.workdir}/final-viral-score.tsv \
            {params.workdir}/final-viral-combined-for-dramv.fa \
            {params.workdir}/viral-affi-contigs-for-dramv.tab \
        2>> {log} 1>&2
        """


rule viruses__annotate__virsorter2__all:
    input:
        rules.viruses__annotate__virsorter2.output,
