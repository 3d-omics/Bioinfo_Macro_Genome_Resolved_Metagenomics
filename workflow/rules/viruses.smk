include: "viruses/cluster.smk"
include: "viruses/annotate.smk"
include: "viruses/quantify.smk"
include: "viruses/multiqc.smk"


rule viruses__all:
    input:
        rules.viruses__cluster__all.input,
        rules.viruses__annotate__all.input,
        rules.viruses__quantify__all.input,
        rules.viruses__multiqc__all.input,
