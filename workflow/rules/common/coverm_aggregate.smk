rule coverm__aggregate:
    """Aggregate coverm reports"""
    input:
        ["{sample}.{method}.tsv.gz" for sample in ["sample"]],
    output:
        "coverm.{method}.tsv.gz",
    conda:
        "../../../environments/coverm.yml"
    params:
        input_dir=".",
    shell:
        """
        ( csvstack --tabs {input} \
        | sed 's/ Read Count//' \
        | csvformat --out-tabs \
        | gzip --best \
        > {output} \
        ) 2> {log}
        """
