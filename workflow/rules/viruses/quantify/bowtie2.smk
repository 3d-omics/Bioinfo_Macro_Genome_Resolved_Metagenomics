rule viruses__quantify__bowtie2__build:
    """Index dereplicader"""
    input:
        contigs=MMSEQS / "rep_seq.fa.gz",
    output:
        mock=multiext(
            str(VINDEX / "viruses"),
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        VINDEX / "virues.log",
    conda:
        "../../../environments/bowtie2_samtools.yml"
    params:
        index_prefix=lambda w: VINDEX / "viruses",
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            {input.contigs} \
            {params.index_prefix} \
        2> {log} 1>&2
        """


rule viruses__quantify__bowtie2__build__all:
    input:
        rules.viruses__quantify__bowtie2__build.output,


rule viruses__quantify__bowtie2__map:
    """Align one sample to the dereplicated genomes"""
    input:
        mock=multiext(
            str(VINDEX / "viruses"),
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
        forward_=PRE_CLEAN / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=PRE_CLEAN / "{sample_id}.{library_id}_2.fq.gz",
    output:
        bam=VBOWTIE2 / "{sample_id}.{library_id}.bam",
    log:
        VBOWTIE2 / "{sample_id}.{library_id}.log",
    conda:
        "../../../environments/bowtie2_samtools.yml"
    params:
        samtools_mem=params["quantify"]["bowtie2"]["samtools_mem"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
        index_prefix=lambda w: VINDEX / "viruses",
    shell:
        """
        find \
            $(dirname {output.bam}) \
            -name "$(basename {output.bam}).tmp.*.bam" \
            -delete \
        2> {log} 1>&2

        ( bowtie2 \
            -x {params.index_prefix} \
            -1 {input.forward_} \
            -2 {input.reverse_} \
            --threads {threads} \
            --rg-id '{params.rg_id}' \
            --rg '{params.rg_extra}' \
        | samtools sort \
            -l 9 \
            -M \
            -m {params.samtools_mem} \
            -o {output.bam} \
            --threads {threads} \
        ) 2>> {log} 1>&2
        """


rule viruses__quantify__bowtie2__map__all:
    """Align all samples to the dereplicated genomes"""
    input:
        [
            VBOWTIE2 / f"{sample_id}.{library_id}.bam"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],


rule viruses__quantify__bowtie2__all:
    input:
        rules.viruses__quantify__bowtie2__build__all.input,
        rules.viruses__quantify__bowtie2__map__all.input,
