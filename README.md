[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.1-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

# Plasmid Outbreak Reporting Tool (PORT)

<p align="center">
    <a href="https://creativecommons.org/licenses/by/4.0/">
        <img src="https://mirrors.creativecommons.org/presskit/buttons/88x31/png/by.png" alt="CC BY 4.0 License" height="31"/>
    </a>
</p>

# PORT

An uptomated pipeline for plasmid outbreak investigation.

<p align="center">
<img src="https://github.com/jqbeh/PORT/blob/main/docs/_figures/port_logo.png?raw=true" alt="alt text" width="500">
</p>

## Usage

Run from inside the `PORT` folder. Docker must be installed and running, or use `-profile conda` (see the documentation).

**From raw Nanopore reads** (one FASTQ/FASTQ.GZ file per isolate):
```bash
nextflow run main.nf --input_dir /path/to/reads --output_dir /path/to/results -resume
```

**From existing assemblies** (one FASTA/FA file per isolate):
```bash
nextflow run main.nf --assemblies /path/to/fastas --output_dir /path/to/results -resume
```

**With all optional steps:**
```bash
nextflow run main.nf \
  --input_dir /path/to/reads \
  --output_dir /path/to/results \
  --assembler autocycler \
  --read_type ont_r10 \
  --clustering pling \
  --bakta_db_type light \
  --max_cpus 8 --max_memory 16.GB \
  -resume
```

## Options

### Input / output
| Option | Description | Default |
|---|---|---|
| `--input_dir` | Folder of Nanopore FASTQ/FASTQ.GZ files, one per isolate. The file name is the isolate ID; Illumina-style files (`_1`, `_2`, `_R1`, `_R2`) are skipped | not set |
| `--assemblies` | Folder of assembled FASTA/FA files, one per isolate. Skips read QC and assembly; used instead of `--input_dir` if both are given | not set |
| `--output_dir` | Results folder | `output/` in the pipeline folder |

### Assembly
| Option | Description | Default |
|---|---|---|
| `--assembler` | Long-read assembler: `autocycler` or `dragonflye` | `autocycler` |
| `--read_type` | Read type for Autocycler: `ont_r10`, `ont_r9`, `pacbio_clr`, `pacbio_hifi` | `ont_r10` |
| `--medaka_model` | Medaka polishing model for Dragonflye | `r1041_e82_400bps_sup` |

### Plasmid extraction
| Option | Description | Default |
|---|---|---|
| `--plasmid_min_length` | Minimum length (bp, inclusive) of a circular contig to be saved as a plasmid (`<isolate>.p1.fasta`, …) | `1000` |
| `--plasmid_max_length` | Maximum length (bp, exclusive) of a circular contig to be saved as a plasmid | `500000` |

### Bakta plasmid annotation
| Option | Description | Default |
|---|---|---|
| `--bakta_db` | Path to an existing Bakta database folder (`db/` or `db-light/`, database v6) | not set (download) |
| `--bakta_db_type` | Database to download when `--bakta_db` is not set: `light` (~1.3 GB download, ~3.9 GB unpacked) or `full` (~30 GB download, ~84 GB unpacked) | `light` |
| `--bakta_db_cache` | Where a downloaded Bakta database is kept and reused between runs | `databases/bakta/` in the pipeline folder |
| `--skip_bakta` | Skip Bakta annotation | off |

### Plasmid clustering (Pling)
| Option | Description | Default |
|---|---|---|
| `--clustering` | Set to `pling` to cluster all extracted plasmids from all isolates with [Pling](https://github.com/iqbal-lab-org/pling) (needs ≥ 2 plasmids) | off |
| `--pling_dcj` | DCJ-Indel distance threshold | `4` |
| `--pling_containment_distance` | Containment distance threshold | `0.5` |
| `--pling_sourmash` | Use sourmash pre-filtering (faster for large datasets) | off |
| `--pling_args` | Extra options passed as-is to `pling cluster align`, e.g. `--pling_args "--timelimit 60"` | `''` |

### Resources
| Option | Description | Default |
|---|---|---|
| `--max_cpus` | Maximum CPUs any single step may use | `12` |
| `--max_memory` | Maximum memory any single step may use | `16.GB` |
| `--max_time` | Maximum run time any single step may use | `10.h` |

### Conda profile
| Option | Description | Default |
|---|---|---|
| `--conda_env` | Name of the conda environment checked when running with `-profile conda` | `port_env` |

### Nextflow options (single dash)
| Option | Description |
|---|---|
| `-profile conda` | Run tools from an activated conda environment instead of Docker (default profile) |
| `-resume` | Reuse results of steps that already finished in a previous run |

## Output

| Folder | Contents |
|---|---|
| `long_read_stats/` | NanoPlot read QC reports (reads input only) |
| `assemblies/` | Assemblies (`.fasta`, plus `.gfa` from Autocycler) |
| `assemblies/plasmids/` | One FASTA per plasmid (`<isolate>.p1.fasta`, …) and `<isolate>_plasmids.tsv` |
| `quast_summary/` | QUAST assembly statistics |
| `amrfinder_results/` | AMRFinderPlus on whole assemblies |
| `plasmid_amrfinder_results/` | AMRFinderPlus on extracted plasmids |
| `mobsuite_results/` | MOB-suite `mob_recon` on whole assemblies |
| `plasmid_mobtyper_results/` | MOB-typer on extracted plasmids |
| `plasmidfinder/` | PlasmidFinder replicon hits |
| `bakta/` | Bakta annotation, one folder per plasmid (`bakta/<isolate>.pN/`) |
| `pling/` | Pling clusters and network visualisations (with `--clustering pling` only) |

## Documentation

Documentation for PORT can be found [here](https://jqbeh.github.io/PORT/)

## Citation

If you use PORT in your research, please cite this repository.

## License

Distributed under the MIT License.
