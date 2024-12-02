rule preprocess__nonpareil__run:
    """Run nonpareil over one sample

    NOTE: Nonpareil only ask for one of the pair-end reads
    NOTE: it has to be fastq. The process substitution trick does not work
    NOTE: in case that nonpareil fails for low coverage samples, it creates empty files
    """
    input:
        PRE_CLEAN / "{sample_id}.{library_id}_1.fq.gz",
    output:
        redund_val=touch(PRE_NONPAREIL / "{sample_id}.{library_id}.npa"),
        mate_distr=touch(PRE_NONPAREIL / "{sample_id}.{library_id}.npc"),
        log=touch(PRE_NONPAREIL / "{sample_id}.{library_id}.npl"),
        redund_sum=touch(PRE_NONPAREIL / "{sample_id}.{library_id}.npo"),
    log:
        PRE_NONPAREIL / "{sample_id}.{library_id}.log",
    # conda:
    #     "../../environments/nonpareil.yml"
    # params:
    #     prefix=lambda w: PRE_NONPAREIL / f"{w.sample_id}.{w.library_id}",
    params:
        alg="kmer",
        infer_X=True,
        extra="",
    resources:
        mem_mb=8 * 1024,
        runtime=6 * 60,
    # shell:
    #     """
    #     nonpareil \
    #         -s {input} \
    #         -T kmer \
    #         -b {params.prefix} \
    #         -f fastq \
    #         -t {threads} \
    #     2> {log} 1>&2 || true
    #     """
    wrapper:
        "v5.2.1/bio/nonpareil/infer"


rule preprocess__nonpareil__plot:
    """Export nonpareil results to json for multiqc"""
    input:
        npo=PRE_NONPAREIL / "{sample_id}.{library_id}.npo",
    output:
        json=PRE_NONPAREIL / "{sample_id}.{library_id}.json",
    log:
        PRE_NONPAREIL / "{sample_id}.{library_id}.json.log",
    # conda:
    #     "../../environments/nonpareil.yml"
    # params:
    #     labels=lambda w: f"{w.sample_id}.{w.library_id}",
    # shell:
    #     """
    #     if [ ! -s {input} ] ; then
    #         echo "Empty nonpareil output for {input}." > {log}
    #         touch {output}
    #         exit
    #     fi

    #     Rscript --no-init-file $(which NonpareilCurves.R) \
    #         --labels {params.labels} \
    #         --json {output} \
    #         {input} \
    #     2> {log} 1>&2
    #     """
    wrapper:
        "v5.2.1/bio/nonpareil/plot"

rule preprocess__nonpareil__all:
    """Run nonpareil over all samples and produce JSONs for multiqc"""
    input:
        [
            PRE_NONPAREIL / f"{sample_id}.{library_id}.json"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
