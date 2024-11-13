include: "megahit_functions.smk"


rule assemble__megahit:
    """Run megahit over one sample, merging all libraries in the process

    Note: the initial rm -rf is to delete the folder that snakemake creates.
    megahit refuses to overwrite an existing folder
    """
    input:
        forwards=get_forwards_from_assembly_id,
        reverses=get_reverses_from_assembly_id,
    output:
        workdir=temp(directory(ASSEMBLE_MEGAHIT / "{assembly_id}.dir")),
    log:
        log=ASSEMBLE_MEGAHIT / "{assembly_id}.log",
    conda:
        "../../environments/megahit.yml"
    params:
        min_contig_len=params["assemble"]["megahit"]["min_contig_len"],
        forwards=aggregate_forwards_for_megahit,
        reverses=aggregate_reverses_for_megahit,
    retries: 5
    group: "assemble__megahit__{assembly_id}"
    shell:
        """
        megahit \
            --num-cpu-threads {threads} \
            --min-contig-len {params.min_contig_len} \
            --verbose \
            --force \
            --out-dir {output.workdir} \
            --continue \
            -1 {params.forwards} \
            -2 {params.reverses} \
        2> {log} 1>&2
        """


rule assemble__megahit__rename:
    input:
        workdir=directory(ASSEMBLE_MEGAHIT / "{assembly_id}.dir"),
    output:
        fasta=ASSEMBLE_MEGAHIT / "{assembly_id}.fa.gz",
    log:
        log=ASSEMBLE_MEGAHIT / "{assembly_id}.rename.log",
    conda:
        "../../environments/megahit.yml"
    group: "assemble__megahit__{assembly_id}"
    params:
        assembly_id=lambda w: w.assembly_id
    shell:
        """
        ( seqtk seq \
            {input.workdir}/final.contigs.fa \
        | cut -f 1 -d " " \
        | paste - - \
        | awk \
            '{{printf(">{params.assembly_id}:bin_NA@contig_%08d\\n%s\\n", NR, $2)}}' \
        | bgzip \
            -l 9 \
            -@ {threads} \
        > {output.fasta} \
        ) 2> {log}
        """


rule assemble__megahit__archive:
    input:
        workdir=directory(ASSEMBLE_MEGAHIT / "{assembly_id}.dir"),
    output:
        tarball=ASSEMBLE_MEGAHIT / "{assembly_id}.tar.gz",
    log:
        log=ASSEMBLE_MEGAHIT / "{assembly_id}.archive.log",
    conda:
        "../../environments/megahit.yml"
    group: "assemble__megahit__{assembly_id}"
    shell:
        """
        tar \
            --create \
            --file {output.tarball} \
            --use-compress-program="pigz --best --processes {threads}" \
            --verbose \
            {input.workdir} \
        2> {log} 1>&2
        """


rule assemble__megahit__all:
    """Rename all assemblies contigs to avoid future collisions"""
    input:
        [
            ASSEMBLE_MEGAHIT / f"{assembly_id}.fa.gz" 
            for assembly_id in ASSEMBLIES
        ],
        [
            ASSEMBLE_MEGAHIT / f"{assembly_id}.tar.gz" 
            for assembly_id in ASSEMBLIES
        ],
