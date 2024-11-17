rule preprocess__kraken2__assign:
    """
    Run kraken2 over all samples at once using the /dev/shm/ trick.

    NOTE: /dev/shm may be not empty after the job is done.
    """
    input:
        forwards=[
            PRE_FASTP / f"{sample_id}.{library_id}_1.fq.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
        rerverses=[
            PRE_FASTP / f"{sample_id}.{library_id}_2.fq.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
        database=lambda w: features["databases"]["kraken2"][w.kraken2_db],
    output:
        out_gzs=[
            PRE_KRAKEN2 / "{kraken2_db}" / f"{sample_id}.{library_id}.out.gz"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
        reports=[
            PRE_KRAKEN2 / "{kraken2_db}" / f"{sample_id}.{library_id}.report"
            for sample_id, library_id in SAMPLE_LIBRARY
        ],
    log:
        PRE_KRAKEN2 / "{kraken2_db}.log",
    params:
        in_folder=PRE_FASTP,
        out_folder=lambda w: PRE_KRAKEN2 / w.kraken2_db,
        kraken_db_name="{kraken2_db}",
    threads: 8
    resources:
        mem_mb=800 * 1024 * 1024,
        runtime=24 * 60,
    conda:
        "../../environments/kraken2.yml"
    shell:
        """
        {{
            echo Running kraken2 in $(hostname) 2>> {log} 1>&2

            mkdir --parents /dev/shm/{params.kraken_db_name}
            mkdir --parents {params.out_folder}

            rsync \
                --archive \
                --progress \
                --recursive \
                --times \
                --verbose \
                --chown $(whoami):$(whoami) \
                --chmod u+rw \
                {input.database}/*.k2d \
                /dev/shm/{params.kraken_db_name} \
            2>> {log} 1>&2

            for file in {input.forwards} ; do \

                sample_id=$(basename $file _1.fq.gz)
                forward={params.in_folder}/${{sample_id}}_1.fq.gz
                reverse={params.in_folder}/${{sample_id}}_2.fq.gz
                output={params.out_folder}/${{sample_id}}.out.gz
                report={params.out_folder}/${{sample_id}}.report
                log={params.out_folder}/${{sample_id}}.log

                echo $(date) Processing $sample_id 2>> {log} 1>&2

                kraken2 \
                    --db /dev/shm/{params.kraken_db_name} \
                    --threads {threads} \
                    --gzip-compressed \
                    --paired \
                    --output >(pigz --processes {threads} --best > $output) \
                    --report $report \
                    --memory-mapping \
                    $forward \
                    $reverse \
                2> $log 1>&2

            done
        }} || {{
            echo "Failed job" 2>> {log} 1>&2
        }}

        rm --force --recursive --verbose /dev/shm/{params.kraken_db_name} 2>>{log} 1>&2
        """


rule preprocess__kraken2__bracken:
    input:
        database=lambda w: features["databases"]["kraken2"][w.kraken2_db],
        report=PRE_KRAKEN2 / "{kraken2_db}" / "{sample_id}.{library_id}.report",
    output:
        bracken=touch(PRE_KRAKEN2 / "{kraken2_db}" / "{sample_id}.{library_id}.bracken"),
    log:
        PRE_KRAKEN2 / "{kraken2_db}" / "{sample_id}.{library_id}.bracken.log",
    conda:
        "../../environments/kraken2.yml"
    params:
        extra=params["preprocess"]["kraken2"]["bracken"]["extra"],
    shell:
        """
        if [ ! -s {input.report} ] ; then
            echo "Empty report. Skipping" 2> {log} 1>&2
            exit 0
        fi

        bracken \
            -d {input.database} \
            -i {input.report} \
            -o {output.bracken} \
            {params.extra} \
        2> {log} 1>&2
        """


rule preprocess__kraken2__all:
    input:
        [
            PRE_KRAKEN2 / f"{kraken2_db}" / f"{sample_id}.{library_id}.bracken"
            for sample_id, library_id in SAMPLE_LIBRARY
            for kraken2_db in KRAKEN2_DBS
        ],
