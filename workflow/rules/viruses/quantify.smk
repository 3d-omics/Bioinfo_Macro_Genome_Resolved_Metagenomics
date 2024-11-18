include: "quantify/bowtie2.smk"
include: "quantify/coverm.smk"


rule viruses__quantify__all:
    input:
        rules.viruses__quantify__bowtie2__all.input,
        rules.viruses__quantify__coverm__all.input,
