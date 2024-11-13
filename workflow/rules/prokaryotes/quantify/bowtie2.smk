rule prokaryotes__quantify__bowtie2__build:
    """Index dereplicader"""
    input:
        contigs=PROK_ANN / "drep.{secondary_ani}.fa.gz",
    output:
        mock=multiext(
            str(QUANT_INDEX / "drep.{secondary_ani}."),
            "1.bt2",
            "2.bt2",
            "3.bt2",
            "4.bt2",
            "rev.1.bt2",
            "rev.2.bt2",
        ),
    log:
        QUANT_INDEX / "drep.{secondary_ani}.log",
    conda:
        "../../../environments/bowtie2_samtools.yml"
    params:
        index_prefix=lambda w: QUANT_INDEX / "drep.{secondary_ani}.",
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            {input.contigs} \
            {params.index_prefix} \
        2> {log} 1>&2
        """


rule prokaryotes__quantify__bowtie2__build__all:
    input:
        [
            QUANT_INDEX / f"drep.{secondary_ani}.{extension}"
            for secondary_ani in SECONDARY_ANIS
            for extension in [
                "1.bt2",
                "2.bt2",
                "3.bt2",
                "4.bt2",
                "rev.1.bt2",
                "rev.2.bt2",
            ]
        ],


rule prokaryotes__quantify__bowtie2__map:
    """Align one sample to the dereplicated genomes"""
    input:
        mock=multiext(
            str(QUANT_INDEX / "drep.{secondary_ani}."),
            "1.bt2",
            "2.bt2",
            "3.bt2",
            "4.bt2",
            "rev.1.bt2",
            "rev.2.bt2",
        ),
        forward_=PRE_CLEAN / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=PRE_CLEAN / "{sample_id}.{library_id}_2.fq.gz",
        reference=PROK_ANN / "drep.{secondary_ani}.fa.gz",
        fai=PROK_ANN / "drep.{secondary_ani}.fa.gz.fai",
    output:
        bam=QUANT_BOWTIE2 / "drep.{secondary_ani}" / "{sample_id}.{library_id}.bam",
    log:
        QUANT_BOWTIE2 / "drep.{secondary_ani}" / "{sample_id}.{library_id}.log",
    conda:
        "../../../environments/bowtie2_samtools.yml"
    params:
        samtools_mem=params["quantify"]["bowtie2"]["samtools_mem"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
        index_prefix=lambda w: QUANT_INDEX / "drep.{secondary_ani}",
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
            --reference {input.reference} \
            --threads {threads} \
        ) 2>> {log} 1>&2
        """


rule prokaryotes__quantify__bowtie2__map__all:
    """Align all samples to the dereplicated genomes"""
    input:
        [
            QUANT_BOWTIE2 / f"drep.{secondary_ani}" / f"{sample_id}.{library_id}.bam"
            for sample_id, library_id in SAMPLE_LIBRARY
            for secondary_ani in SECONDARY_ANIS
        ],


rule prokaryotes__quantify__bowtie2__all:
    input:
        rules.prokaryotes__quantify__bowtie2__build__all.input,
        rules.prokaryotes__quantify__bowtie2__map__all.input,
