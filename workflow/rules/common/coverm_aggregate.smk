rule coverm__aggregate:
    """Aggregate coverm reports"""
    input:
        ["{sample}.{method}.tsv.gz" for sample in ["sample"]],
    output:
        "coverm.{method}.tsv.gz",
    log:
        "coverm.{method}.log",
    conda:
        "../../../environments/coverm.yml"
    shell:
        """
        ( csvstack --tabs {input} \
        | csvformat --out-tabs \
        | gzip --best \
        > {output} \
        ) 2> {log}
        """
