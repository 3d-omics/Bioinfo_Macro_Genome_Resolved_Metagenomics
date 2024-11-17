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
        separator="@",
        extra="--min-covered-fraction 0"
    shell:
        """
        ( coverm genome \
            --bam-files {input} \
            --methods {params.method} \
            --separator {params.separator} \
            {params.extra} \
        | gzip --best \
        > {output} \
        ) 2> {log}
        """
