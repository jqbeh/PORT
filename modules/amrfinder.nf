process AMRFINDERPLUS_RUN {
    tag "$sample_id"
    label 'process_medium'
    label 'amrfinderplus_container'

    publishDir "${params.output_dir}/amrfinder_results", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(sample_id), path(fasta)

    output:
    tuple val(sample_id), path("${prefix}.tsv"), emit: report

    script:
    prefix   = "${sample_id}_amrfinder"

    """
    amrfinder -n $fasta -o ${prefix}.tsv --threads $task.cpus --name "$sample_id"
    """
}

// AMRFinderPlus on the extracted plasmids of one isolate.
// All <isolate>.pN.fasta files are combined into one multi-FASTA so that each
// row's "Contig id" is the plasmid ID (e.g. AUSMDU00123.p1).
process AMRFINDERPLUS_PLASMIDS {
    tag "$sample_id"
    label 'process_medium'
    label 'amrfinderplus_container'

    publishDir "${params.output_dir}/plasmid_amrfinder_results", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(sample_id), path(plasmids, stageAs: 'plasmids/*')

    output:
    tuple val(sample_id), path("${sample_id}_plasmids_amrfinder.tsv"), emit: report

    script:
    """
    cat plasmids/*.fasta > ${sample_id}_plasmids.fasta
    amrfinder -n ${sample_id}_plasmids.fasta -o ${sample_id}_plasmids_amrfinder.tsv --threads $task.cpus --name "$sample_id"
    """
}
