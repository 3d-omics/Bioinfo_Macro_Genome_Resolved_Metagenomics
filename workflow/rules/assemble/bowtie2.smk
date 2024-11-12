rule assemble__bowtie2__build:
    """Index a megahit assembly"""
    input:
        contigs=ASSEMBLE_MEGAHIT / "{assembly_id}.fa.gz",
    output:
        mock=multiext(
            str(ASSEMBLE_INDEX / "{assembly_id}"),
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        ASSEMBLE_INDEX / "{assembly_id}.log",
    conda:
        "../../environments/bowtie2_samtools.yml"
    resources:
        attempt=get_attempt,
    retries: 5
    params:
        index_prefix=lambda w: ASSEMBLE_INDEX / f"{w.assembly_id}",
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            {input.contigs} \
            {params.index_prefix} \
        2> {log}.{resources.attempt} 1>&2

        mv {log}.{resources.attempt} {log}
        """


rule assemble__bowtie2__build__all:
    """Index all megahit assemblies"""
    input:
        [
            ASSEMBLE_INDEX / f"{assembly_id}.{extension}"
            for assembly_id in ASSEMBLIES
            for extension in [
                "1.bt2",
                "2.bt2",
                "3.bt2",
                "4.bt2",
                "rev.1.bt2",
                "rev.2.bt2",
            ]
        ],


rule assemble__bowtie2__map:
    """Map one sample to one megahit assembly"""
    input:
        mock=multiext(
            str(ASSEMBLE_INDEX / "{assembly_id}"),
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
        forward_=PRE_BOWTIE2 / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=PRE_BOWTIE2 / "{sample_id}.{library_id}_2.fq.gz",
    output:
        bam=ASSEMBLE_BOWTIE2 / "{assembly_id}.{sample_id}.{library_id}.bam",
    log:
        ASSEMBLE_BOWTIE2 / "{assembly_id}.{sample_id}.{library_id}.log",
    conda:
        "../../environments/bowtie2_samtools.yml"
    params:
        index_prefix=lambda w: ASSEMBLE_INDEX / f"{w.assembly_id}",
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
    resources:
        attempt=get_attempt,
    retries: 5
    shell:
        """
        find \
            $(dirname {output.bam}) \
            -name "$(basename {output.bam}).tmp.*.bam" \
            -delete \
        2> {log}.{resources.attempt} 1>&2

        ( bowtie2 \
            -x {params.index_prefix} \
            -1 {input.forward_} \
            -2 {input.reverse_} \
            --threads {threads} \
            --rg-id '{params.rg_id}' \
            --rg '{params.rg_extra}' \
        | samtools sort \
            -l 9 \
            -o {output.bam} \
            --threads {threads} \
        ) 2>> {log}.{resources.attempt} 1>&2

        mv {log}.{resources.attempt} {log}
        """


rule assemble__bowtie2__map__all:
    """Map all samples to all the assemblies that they belong to"""
    input:
        [
            ASSEMBLE_BOWTIE2 / f"{assembly_id}.{sample_id}.{library_id}.bam"
            for assembly_id, sample_id, library_id in ASSEMBLY_SAMPLE_LIBRARY
        ],


rule assemble__bowtie2__all:
    input:
        rules.assemble__bowtie2__build__all.input,
        rules.assemble__bowtie2__map__all.input,
