# Parameters

### 💡 Basic parameters

| Parameter        | Description                                     | Default                |
| ---------------- | ----------------------------------------------- | ---------------------- |
| `--input_dir`    | Directory containing FASTQ files                | `input/`               |
| `--assemblies`   | Directory containing pre-assembled FASTA files  | `null`                 |
| `--output_dir`   | Output directory for all results                | `output/`              |
| `--assembler`    | Assembler to use (`autocycler` or `dragonflye`) | `autocycler`           |
| `--read_type`    | Read type (e.g., `ont_r9`)                      | `ont_r10`              |
| `--medaka_model` | Medaka model (for Dragonflye polishing)         | `r1041_e82_400bps_sup` |
| `--plasmid_min_length` | Minimum circular contig length (bp, inclusive) kept as a plasmid | `1000` |
| `--plasmid_max_length` | Maximum circular contig length (bp, exclusive) kept as a plasmid | `500000` |
| `--clustering` | Plasmid clustering to run on all extracted plasmids: `pling` | not set (no clustering) |
| `--pling_dcj` | Pling DCJ-Indel distance threshold | `4` |
| `--pling_containment_distance` | Pling containment distance threshold | `0.5` |
| `--pling_sourmash` | Sourmash pre-filter in Pling (faster for large datasets) | `false` |
| `--pling_args` | Extra options passed to `pling cluster align` | `''` |
| `--skip_bakta` | Skip Bakta annotation of plasmids | `false` |
| `--bakta_db` | Existing Bakta DB folder (`db/` or `db-light/`) | not set (download) |
| `--bakta_db_type` | DB type to download if `--bakta_db` is not set: `light` or `full` | `light` |
| `--bakta_db_cache` | Where the downloaded Bakta DB is kept between runs | `databases/bakta/` |


### Advanced parameters


### PORT Usage

```
usage: panaroo [-h] options
```

