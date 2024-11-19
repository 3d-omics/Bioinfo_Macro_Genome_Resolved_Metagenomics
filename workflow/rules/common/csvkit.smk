rule csvkit__csvstack:
    """Stack by row multiple tsvs"""
    input:
        ["{sample}.{method}.tsv.gz" for sample in ["sample"]],
    output:
        "coverm.{method}.tsv.gz",
    log:
        "coverm.{method}.log",
    conda:
        "../../../environments/csvkit.yml"
    shell:
        """
        ( csvstack --tabs {input} \
        | csvformat --out-tabs \
        | gzip --best \
        > {output} \
        ) 2> {log}
        """


rule csvkit__csvjoin:
    """Do a left join on multiple tsvs"""
    input:
        ["sample1.tsv.gz", "sample2.tsv.gz"],
    output:
        "joined.tsv.gz",
    log:
        "joined.log",
    conda:
        "../../../environments/csvkit.yml"
    shell:
        """
        ( csvjoin \
            --tabs \
            --left \
            --columns 1 \
            {input} \
        | csvformat \
            --out-tabs \
        | gzip \
            --best \
        > {output} \
        ) 2> {log}
        """
