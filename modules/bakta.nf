// ─────────────────────────────────────────────
// Bakta annotation of extracted plasmids
// https://github.com/oschwengers/bakta
// ─────────────────────────────────────────────

// Download the Bakta database once and keep it for later runs (storeDir).
// type 'light' -> <bakta_db_cache>/db-light (~1.3 GB download, ~3.9 GB unpacked)
// type 'full'  -> <bakta_db_cache>/db       (~30 GB download, ~84 GB unpacked)
// The AMRFinderPlus DB bundled inside the Bakta DB is refreshed afterwards so it
// matches the AMRFinderPlus version shipped in the Bakta container.
process BAKTA_DB_DOWNLOAD {
    tag "$db_type"
    label 'process_low'
    label 'process_long'
    label 'bakta_container'

    storeDir "${params.bakta_db_cache}"

    input:
        val(db_type)

    output:
        path(db_name), emit: db

    script:
    db_name = db_type == 'full' ? 'db' : 'db-light'
    """
    bakta_db download --output . --type ${db_type}
    amrfinder_update --force_update --database ${db_name}/amrfinderplus-db/
    """
}

// Annotate one plasmid; results go to bakta/<plasmid_id>/
process BAKTA {
    tag "$plasmid_id"
    label 'process_medium'
    label 'bakta_container'

    publishDir "${params.output_dir}/bakta", mode: 'copy'

    input:
        tuple val(sample_id), val(plasmid_id), path(fasta)
        path(db)

    output:
        tuple val(sample_id), val(plasmid_id), path("${plasmid_id}"),                 emit: results
        tuple val(sample_id), val(plasmid_id), path("${plasmid_id}/${plasmid_id}.tsv"),  emit: tsv
        tuple val(sample_id), val(plasmid_id), path("${plasmid_id}/${plasmid_id}.gbff"), emit: gbff

    script:
    """
    export MPLCONFIGDIR=\$PWD/.mplconfig

    # Replicon table: every input sequence is a circular plasmid named after its plasmid ID
    contig=\$(grep -m1 '^>' ${fasta} | sed 's/^>//; s/[[:space:]].*//')
    printf '%s\\t%s\\tplasmid\\tcircular\\t%s\\n' "\$contig" "${plasmid_id}" "${plasmid_id}" > replicons.tsv

    bakta \\
        --db ${db} \\
        --output ${plasmid_id} \\
        --prefix ${plasmid_id} \\
        --replicons replicons.tsv \\
        --threads ${task.cpus} \\
        --force \\
        ${fasta}
    """
}
