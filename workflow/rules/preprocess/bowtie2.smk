include: "bowtie2_functions.smk"


rule preprocess__bowtie2__build:
    """Build bowtie2 index for a reference

    NOTE: Let the script decide to use a small or a large index based on the size of
    the reference genome.
    """
    input:
        reference=PRE_HOSTS / "{host}.fa.gz",
    output:
        multiext(
            str(PRE_BUILD / "{host}"),
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        PRE_BUILD / "{host}.log",
    conda:
        "../../environments/bowtie2.yml"
    params:
        prefix=lambda w: str(PRE_BUILD / f"{w.host}"),
    cache: "omit-software"
    group:
        "preprocess__{host}"
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            {input.reference} \
            {params.prefix} \
        2> {log} 1>&2
        """


rule preprocess__bowtie2__build__all:
    """Build bowtie2 index for all host genomes"""
    input:
        [
            PRE_BUILD / f"{host}.{extension}"
            for extension in [
                "1.bt2",
                "2.bt2",
                "3.bt2",
                "4.bt2",
                "rev.1.bt2",
                "rev.2.bt2",
            ]
            for host in HOST_NAMES
        ],


rule preprocess__bowtie2__map:
    """Map one library to reference genome using bowtie2

    Output SAM file is piped to samtools sort to generate a CRAM file.
    """
    input:
        forward_=get_fastq_for_host_mapping_forward,
        reverse_=get_fastq_for_host_mapping_reverse,
        mock=multiext(
            str(PRE_BUILD / "{host}"),
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    output:
        bam=PRE_BOWTIE2 / "{host}.{sample_id}.{library_id}.bam",
    log:
        PRE_BOWTIE2 / "{host}.{sample_id}.{library_id}.log",
    params:
        index=lambda w: PRE_BUILD / f"{w.host}",
        samtools_extra=params["preprocess"]["bowtie2"]["samtools_extra"],
        bowtie2_extra=params["preprocess"]["bowtie2"]["bowtie2_extra"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
    conda:
        "../../environments/bowtie2.yml"
    group:
        "preprocess__{sample_id}.{library_id}"
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
            -T {output.bam} \
            -o {output.bam} \
        ) 2> {log} 1>&2
        """


rule preprocess__bowtie2__map__all:
    input:
        [
            PRE_BOWTIE2 / f"{host}.{sample_id}.{library_id}.bam"
            for host in HOST_NAMES
            for sample_id, library_id in SAMPLE_LIBRARY
        ],


rule preprocess__bowtie2__fastq:
    """Convert BAM to FASTQ using samtools and using the correct reference

    NOTE: bowtie2 does not like CRAM files, and although can use a BAM file as an input,
    bowtie2 fails to receive a piped SAM input. Therefore, we need to convert the CRAM file to a physical FASTQ file.
    """
    input:
        bam=PRE_BOWTIE2 / "{host}.{sample_id}.{library_id}.bam",
        bai=PRE_BOWTIE2 / "{host}.{sample_id}.{library_id}.bam.bai",
    output:
        forward_=temp(PRE_BOWTIE2 / "{host}.{sample_id}.{library_id}_u1.fq.gz"),
        reverse_=temp(PRE_BOWTIE2 / "{host}.{sample_id}.{library_id}_u2.fq.gz"),
    log:
        PRE_BOWTIE2 / "{host}.{sample_id}.{library_id}.unaligned.log",
    conda:
        "../../environments/bowtie2.yml"
    group:
        "preprocess__{sample_id}.{library_id}"
    shell:
        """
        rm \
            --recursive \
            --force \
            {output.forward_}.collate

        ( samtools view \
            -f 12 \
            -u \
            --threads {threads} \
            {input} \
            "*" \
        | samtools collate \
            -O \
            -u \
            -f \
            -r 1e6 \
            -T {output.forward_}.collate \
            --threads {threads} \
            - \
        | samtools fastq \
            -1 {output.forward_} \
            -2 {output.reverse_} \
            -0 /dev/null \
            -s /dev/null \
            --threads {threads} \
            -c 1 \
            /dev/stdin \
        ) 2> {log} 1>&2
        """


rule preprocess__bowtie2__fastq__all:
    input:
        [
            PRE_BOWTIE2 / f"{host}.{sample_id}.{library_id}_u{end}.fq.gz"
            for host in HOST_NAMES
            for sample_id, library_id in SAMPLE_LIBRARY
            for end in [1, 2]
        ],


rule preprocess__bowtie2__all:
    input:
        rules.preprocess__bowtie2__build__all.input,
        rules.preprocess__bowtie2__map__all.input,
        rules.preprocess__bowtie2__fastq__all.input,
