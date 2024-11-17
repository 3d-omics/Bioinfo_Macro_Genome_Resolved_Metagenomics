rule assemble__quast:
    """Run quast over one the dereplicated mags"""
    input:
        ASSEMBLE_MEGAHIT / "{assembly_id}.fa.gz",
    output:
        directory(ASSEMBLE_QUAST / "{assembly_id}"),
    log:
        ASSEMBLE_QUAST / "{assembly_id}.log",
    conda:
        "../../environments/quast.yml"
    resources:
        mem_mb=8 * 1024,
    shell:
        """
        quast \
            --output-dir {output} \
            --threads {threads} \
            {input} \
        2> {log} 1>&2
        """


rule assemble__quast__all:
    input:
        [
            ASSEMBLE_QUAST / f"{assembly_id}"
            for assembly_id, _, _ in ASSEMBLY_SAMPLE_LIBRARY
        ],
