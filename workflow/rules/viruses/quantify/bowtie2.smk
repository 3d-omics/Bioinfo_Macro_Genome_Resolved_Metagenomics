use rule bowtie2__build as viruses__quantify__bowtie2__build with:
    input:
        ref=MMSEQS / "rep_seq.fa.gz",
    output:
        multiext(
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


rule viruses__quantify__bowtie2__build__all:
    input:
        rules.viruses__quantify__bowtie2__build.output,


use rule bowtie2__map as viruses__quantify__bowtie2__map with:
    input:
        forward_=PRE_CLEAN / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=PRE_CLEAN / "{sample_id}.{library_id}_2.fq.gz",
        mock=multiext(
            str(VINDEX / "viruses"),
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    output:
        VBOWTIE2 / "{sample_id}.{library_id}.bam",
    log:
        VBOWTIE2 / "{sample_id}.{library_id}.log",
    params:
        index=VINDEX / "viruses",
        samtools_extra=params["preprocess"]["bowtie2"]["samtools_extra"],
        bowtie2_extra=params["preprocess"]["bowtie2"]["bowtie2_extra"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,


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
