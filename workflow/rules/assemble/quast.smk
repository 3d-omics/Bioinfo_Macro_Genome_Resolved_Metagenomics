rule assemble__quast__all:
    """Run quast over one the dereplicated mags"""
    input:
        [ASMB_MEGAHIT / f"{assembly_id}.fa.gz" for assembly_id in ASSEMBLIES],
    output:
        directory(ASMB_QUAST),
    log:
        ASSEMBLE / "quast.log",
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
