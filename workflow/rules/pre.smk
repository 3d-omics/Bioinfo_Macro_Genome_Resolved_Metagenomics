rule pre_fastp_trim_one:
    """Run fastp on one library"""
    input:
        forward_=READS / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=READS / "{sample_id}.{library_id}_2.fq.gz",
    output:
        forward_=temp(FASTP / "{sample_id}.{library_id}_1.fq.gz"),
        reverse_=temp(FASTP / "{sample_id}.{library_id}_2.fq.gz"),
        unpaired1=temp(FASTP / "{sample_id}.{library_id}_u1.fq.gz"),
        unpaired2=temp(FASTP / "{sample_id}.{library_id}_u2.fq.gz"),
        html=FASTP / "{sample_id}.{library_id}_fastp.html",
        json=FASTP / "{sample_id}.{library_id}_fastp.json",
    log:
        FASTP / "{sample_id}.{library_id}.log",
    conda:
        "../envs/pre.yml"
    params:
        adapter_forward=get_forward_adapter,
        adapter_reverse=get_reverse_adapter,
        extra=params["fastp"]["extra"],
        length_required=params["fastp"]["length_required"],
    threads: 16
    resources:
        mem_mb=4 * 1024,
        runtime=240,
    shell:
        """
        fastp \
            --in1 {input.forward_} \
            --in2 {input.reverse_} \
            --out1 >(gzip --fast > {output.forward_}) \
            --out2 >(gzip --fast > {output.reverse_}) \
            --unpaired1 >(gzip --fast > {output.unpaired1}) \
            --unpaired2 >(gzip --fast > {output.unpaired2}) \
            --html {output.html} \
            --json {output.json} \
            --verbose \
            --adapter_sequence {params.adapter_forward} \
            --adapter_sequence_r2 {params.adapter_reverse} \
            --length_required {params.length_required} \
            --thread {threads} \
            {params.extra} \
        2> {log} 1>&2
        """


rule pre_fastp_trim_all:
    """Run fastp over all libraries"""
    input:
        [
            FASTP / f"{sample_id}.{library_id}_{end}.fq.gz"
            for sample_id, library_id in SAMPLE_LIB
            for end in "1 2 u1 u2".split(" ")
        ],


rule pre_fastp_fastqc_one:
    """Run fastqc on one library from fastp output"""
    input:
        fq=FASTP / "{sample_id}.{library_id}_{end}.fq.gz",
    output:
        html=FASTP / "{sample_id}.{library_id}_{end}_fastqc.html",
        zip_=FASTP / "{sample_id}.{library_id}_{end}_fastqc.zip",
    log:
        FASTP / "{sample_id}.{library_id}_{end}_fastqc.log",
    conda:
        "../envs/pre.yml"
    shell:
        """
        fastqc \
            --outdir {FASTP} \
            --threads 1 \
            {input.fq} \
        2> {log} 1>&2
        """


rule pre_fastp_fastqc_all:
    """Run fastqc over all libraries after fastp"""
    input:
        [
            FASTP / f"{sample_id}.{library_id}_{end}_fastqc.{extension}"
            for sample_id, library_id in SAMPLE_LIB
            for end in "1 2 u1 u2".split(" ")
            for extension in "html zip".split(" ")
        ],


rule pre_bowtie2_index_host:
    """Build bowtie2 index for the human reference

    Let the script decide to use a small or a large index based on the size of
    the reference genome.
    """
    input:
        reference=features["host"]["fasta"],
    output:
        mock=touch(BOWTIE2 / "host"),
    log:
        BOWTIE2 / "host_index.log",
    conda:
        "../envs/pre.yml"
    params:
        extra=params["bowtie2"]["extra"],
    threads: 8
    resources:
        mem_mb=32 * 1024,
        runtime=24 * 60,
    shell:
        """
        bowtie2-build \
            --threads {threads} \
            {params.extra} \
            {input.reference} \
            {output.mock} \
        2> {log} 1>&2
        """


rule pre_bowtie2_map_host_one:
    """Map one library to reference genome using bowtie2

    Output SAM file is piped to samtools sort to generate a CRAM file.
    """
    input:
        forward_=FASTP / "{sample_id}.{library_id}_1.fq.gz",
        reverse_=FASTP / "{sample_id}.{library_id}_2.fq.gz",
        mock=BOWTIE2 / "host",
        reference=features["host"]["fasta"],
    output:
        cram=BOWTIE2 / "{sample_id}.{library_id}.cram",
    log:
        BOWTIE2 / "{sample_id}.{library_id}.log",
    conda:
        "../envs/pre.yml"
    params:
        extra=params["bowtie2"]["extra"],
        samtools_mem=params["bowtie2"]["samtools"]["mem_per_thread"],
        rg_id=compose_rg_id,
        rg_extra=compose_rg_extra,
    threads: 24
    resources:
        mem_mb=32 * 1024,
        runtime=24 * 60,
    shell:
        """
        (bowtie2 \
            -x {input.mock} \
            -1 {input.forward_} \
            -2 {input.reverse_} \
            --threads {threads} \
            --rg-id '{params.rg_id}' \
            --rg '{params.rg_extra}' \
            {params.extra} \
        | samtools sort \
            -l 9 \
            -M \
            -m {params.samtools_mem} \
            -o {output.cram} \
            --reference {input.reference} \
            --threads {threads} \
        ) 2> {log} 1>&2
        """


rule pre_bowtie2_map_host_all:
    """Map all libraries to reference genome using bowtie2"""
    input:
        [
            BOWTIE2 / f"{sample_id}.{library_id}.cram"
            for sample_id, library_id in SAMPLE_LIB
        ],


rule pre_bowtie2_extract_nonhost_one:
    """
    Keep only pairs unmapped to the human reference genome, sort by name rather
    than by coordinate, and convert to FASTQ.
    """
    input:
        cram=BOWTIE2 / "{sample}.{library}.cram",
        reference=features["host"]["fasta"],
    output:
        forward_=temp(NONHOST / "{sample}.{library}_1.fq.gz"),
        reverse_=temp(NONHOST / "{sample}.{library}_2.fq.gz"),
    log:
        NONHOST / "{sample}.{library}.log",
    conda:
        "../envs/pre.yml"
    threads: 24
    resources:
        runtime=1 * 60,
        mem_mb=32 * 1024,
    shell:
        """
        (samtools view \
            --reference {input.reference} \
            --threads {threads} \
            -u \
            -o /dev/stdout \
            -f 12 \
            {input.cram} \
        | samtools sort \
            -n \
            -u \
            --threads {threads} \
        | samtools fastq \
            -1 {output.forward_} \
            -2 {output.reverse_} \
            -0 /dev/null \
            -c 1 \
            --threads {threads} \
        ) 2> {log} 1>&2
        """


rule pre_bowtie2_extract_nonhost_all:
    """Extract nonhost reads from all libraries"""
    input:
        [
            NONHOST / f"{sample_id}.{library_id}_{end}.fq.gz"
            for sample_id, library_id in SAMPLE_LIB
            for end in "1 2".split(" ")
        ],


rule pre:
    input:
        rules.pre_fastp_trim_all.input,
        rules.pre_fastp_fastqc_all.input,
        rules.pre_bowtie2_map_host_all.input,
