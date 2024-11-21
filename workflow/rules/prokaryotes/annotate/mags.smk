checkpoint prokaryotes__annotate__mags:
    """Separate and decompress all mags from all bins"""
    input:
        [PROK_MAGSCOT / f"{assembly_id}.fa.gz" for assembly_id in ASSEMBLIES],
    output:
        directory(PROK_MAGS),
    log:
        PROK / "mags.log",
    conda:
        "base"
    shell:
        """
        mkdir --parents {output} 2> {log} 1>&2

        ( gzip \
            --decompress \
            --stdout \
            {input} \
        | paste - - \
        | tr -d ">" \
        | tr "@" "\t" \
        | awk \
            '{{print ">" $1 "@" $2 "\\n" $3 > "{output}/" $1 ".fa" }}' \
        ) >> {log} 2>&1
        """


rule prokaryotes__annotate__mags__all:
    input:
        rules.prokaryotes__annotate__mags.output,
