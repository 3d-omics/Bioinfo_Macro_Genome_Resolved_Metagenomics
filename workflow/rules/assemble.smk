include: "assemble/megahit.smk"
include: "assemble/bowtie2.smk"
include: "assemble/coverm.smk"
include: "assemble/quast.smk"
include: "assemble/multiqc.smk"
include: "assemble/kraken2.smk"


rule assemble__all:
    """Run everything in the assemble module"""
    input:
        rules.assemble__megahit__all.input,
        rules.assemble__bowtie2__all.input,
        rules.assemble__coverm__all.input,
        rules.assemble__quast__all.input,
        rules.assemble__kraken2__all.input,
        rules.assemble__multiqc__all.input,
