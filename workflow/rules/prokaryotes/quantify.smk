include: "quantify/bowtie2.smk"
include: "quantify/coverm.smk"


rule prokaryotes__quantify__all:
    input:
        rules.prokaryotes__quantify__bowtie2__all.input,
        rules.prokaryotes__quantify__coverm__all.input,
