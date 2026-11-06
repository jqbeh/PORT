process MOBSUITE_RECON {
    tag "$sample_id"
    label 'process_medium'
    label 'mobsuite_container'

    publishDir "${params.output_dir}/mobsuite_results", mode: 'copy', pattern: "${sample_id}/*"

    input:
        tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}/chromosome.fasta")    , emit: chromosome
    tuple val(sample_id), path("${sample_id}/contig_report.txt")   , emit: contig_report
    tuple val(sample_id), path("${sample_id}/plasmid_*.fasta")     , emit: plasmids        
    tuple val(sample_id), path("${sample_id}/mobtyper_results.txt"), emit: mobtyper_results

    script:
    """
    mob_recon \\
        --infile ${assembly} \\
        --num_threads $task.cpus \\
        --outdir results \\
        --sample_id ${sample_id}
    mv results/ ${sample_id}
    """
}

// MOB-typer on the extracted plasmids of one isolate.
// mob_recon is meant for whole assemblies; mob_typer types sequences that are
// already plasmids. --multi types every contig of the combined FASTA as its own
// plasmid, so each row's sample_id is the plasmid ID (e.g. AUSMDU00123.p1).
process MOBTYPER_PLASMIDS {
    tag "$sample_id"
    label 'process_medium'
    label 'mobsuite_container'

    publishDir "${params.output_dir}/plasmid_mobtyper_results", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(sample_id), path(plasmids, stageAs: 'plasmids/*')

    output:
    tuple val(sample_id), path("${sample_id}_plasmids_mobtyper.tsv"), emit: report

    script:
    """
    cat plasmids/*.fasta > ${sample_id}_plasmids.fasta
    mob_typer \\
        --infile ${sample_id}_plasmids.fasta \\
        --multi \\
        --num_threads $task.cpus \\
        --out_file ${sample_id}_plasmids_mobtyper.tsv
    """
}
