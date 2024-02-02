rule _viral__cluster__genomad:
    input:
        fasta=MEGAHIT / "{assembly_id}.fa.gz",
        database=features["databases"]["genomad"],
    output:
        plasmid=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_plasmid.fna",
        plasmid_genes=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_plasmid_genes.tsv",
        plasmid_proteins=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_plasmid_proteins.faa",
        plasmid_summary=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_plasmid_summary.tsv",
        json=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_summary.json",
        virus=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_virus.fna",
        virus_genes=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_virus_genes.tsv",
        virus_proteins=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_virus_proteins.faa",
        virus_summary_tsv=GENOMADC / "{assembly_id}_summary" / "{assembly_id}_virus_summary.tsv",
    log:
        GENOMADC / "{assembly_id}.log",
    conda:
        "__environment__.yml"
    threads: 24
    params:
        filtering=params["viral"]["genomad"]["filtering"],
        workdir=GENOMADC,
        extra=params["viral"]["genomad"]["extra"],
        use_cuda=params["viral"]["genomad"]["use_cuda"],
    resources:
        mem_mb=32 * 1024,
    shadow: "minimal"
    shell:
        """
        {params.use_cuda}

        genomad end-to-end \
            {params.filtering} \
            --cleanup \
            --restart \
            --verbose \
            --threads {threads} \
            {params.extra} \
            {input.fasta} \
            {params.workdir} \
            {input.database} \
        2> {log} 1>&2
        """


rule viral__cluster__genomad:
    input:
        [
            GENOMADC / f"{assembly_id}_summary" / f"{assembly_id}_virus.fna"
            for assembly_id in ASSEMBLIES
        ],
