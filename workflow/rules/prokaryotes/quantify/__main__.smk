include: "__functions__.smk"
include: "bowtie2.smk"
include: "coverm.smk"


rule prokaryotes__quantify__all:
    input:
        rules.prokaryotes__quantify__bowtie2__all.input,
        rules.prokaryotes__quantify__coverm__all.input,
