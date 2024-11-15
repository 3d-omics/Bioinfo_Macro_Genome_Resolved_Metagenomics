rule coverm__contig:
    input:
        "sample.{method}.bam",
    output:
        "sample.{method}.tsv.gz",
    log:
        "sample.{method}.log",
    conda:
        "../../environments/coverm.yml"
    params:
        method=lambda w: w.method,
    shell:
        """
        ( coverm contig \
            --bam-files {input} \
            --methods {params.method} \
            --proper-pairs-only \
        | cut \
            --fields 1 \
            --delimiter " " \
        | gzip \
            --best \
        > {output} \
        ) 2> {log}
        """
