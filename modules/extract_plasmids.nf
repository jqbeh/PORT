process EXTRACT_PLASMIDS {
    tag "$sample_id"

    label 'process_single'

    publishDir "${params.output_dir}/assemblies/plasmids", mode: 'copy'

    input:
        tuple val(sample_id), path(assembly)
        val(min_len)
        val(max_len)

    output:
        tuple val(sample_id), path("${sample_id}.p*.fasta"), optional: true, emit: plasmids
        tuple val(sample_id), path("${sample_id}_plasmids.tsv"),             emit: summary

    script:
    """
    extract_plasmids.sh ${assembly} ${sample_id} ${min_len} ${max_len}
    """
}
