rule bowtie2__build:
    """Build a bowtie2 index"""
    input:
        ref="reference.fa",
    output:
        multiext(
            "reference",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        "reference.log",
    wrapper:
        "v5.1.0/bio/bowtie2/build"


rule bowtie2__map:
    """Map one library to a reference genome using bowtie2

    Output SAM file is piped to samtools sort to generate a CRAM file.
    """
    input:
        forward_="reads_1.fq.gz",
        reverse_="reads_2.fq.gz",
        mock=multiext(
            "reference",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    output:
        "reads.bam",
    log:
        "reads.log",
    params:
        index="reference",
        samtools_extra="",
        bowtie2_extra="",
        rg_id="",  # compose_rg_id
        rg_extra="",  # compose_rg_extra
    conda:
        "../../environments/bowtie2.yml"
    shell:
        """
        ( bowtie2 \
            -x {params.index} \
            -1 {input.forward_} \
            -2 {input.reverse_} \
            {params.bowtie2_extra} \
            --rg '{params.rg_extra}' \
            --rg-id '{params.rg_id}' \
            --threads {threads} \
        | samtools sort \
            {params.samtools_extra} \
            --threads {threads} \
            -T {output} \
            -o {output} \
        ) 2> {log} 1>&2
        """
