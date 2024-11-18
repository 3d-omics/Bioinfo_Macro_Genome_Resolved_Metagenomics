include: "prokaryotes/cluster.smk"
include: "prokaryotes/annotate.smk"
include: "prokaryotes/quantify.smk"
include: "prokaryotes/multiqc.smk"


rule prokaryotes__all:
    input:
        rules.prokaryotes__cluster__all.input,
        rules.prokaryotes__annotate__all.input,
        rules.prokaryotes__quantify__all.input,
        rules.prokaryotes__multiqc__all.input,
