// ─────────────────────────────────────────────
// Pling: plasmid clustering by containment + DCJ-Indel rearrangement distance
// https://github.com/iqbal-lab-org/pling
// Runs ONCE on all extracted plasmids from all isolates.
// ─────────────────────────────────────────────
process PLING {
    tag "${fastas.size()} plasmids"
    label 'process_high'
    label 'process_long'
    label 'pling_container'

    publishDir "${params.output_dir}", mode: 'copy', pattern: 'pling'

    input:
        path(fastas, stageAs: 'plasmids/*')

    output:
        path('pling'),                                                       emit: results
        path("pling/dcj_thresh_${params.pling_dcj}_graph/objects/typing.tsv"), optional: true, emit: typing

    script:
    def sourmash = params.pling_sourmash ? '--sourmash' : ''
    """
    # Pling runs Snakemake internally; give it writable home/cache dirs inside the container
    export HOME=\$PWD
    export XDG_CACHE_HOME=\$PWD/.cache

    # Input list: absolute path of every plasmid FASTA, one per line.
    # Plasmid IDs in the output are taken from the file names (e.g. AUSMDU00123.p1).
    ls -d -1 \$PWD/plasmids/*.fasta > genomes_list.txt

    pling cluster align genomes_list.txt pling \\
        --containment_distance ${params.pling_containment_distance} \\
        --dcj ${params.pling_dcj} \\
        --cores ${task.cpus} \\
        ${sourmash} \\
        ${params.pling_args}

    cp genomes_list.txt pling/
    """
}
