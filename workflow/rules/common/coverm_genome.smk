rule coverm__genome:
    """Run coverm genome for one library and one mag catalogue"""
    input:
        "sample.{method}.bam",
    output:
        "sample.{method}.tsv.gz",  # it can be tsv too
    conda:
        "../../environments/coverm.yml"
    log:
        "sample.{method}.log",
    params:
        method=lambda w: w.method,
        min_covered_fraction=0,
        separator="@",
    shell:
        """
        ( coverm genome \
            --bam-files {input} \
            --methods {params.method} \
            --separator {params.separator} \
            --min-covered-fraction {params.min_covered_fraction} \
        | gzip --best \
        > {output} \
        ) 2> {log}
        """
