# Quick Start

## Basic usage

### 1. Run with raw Nanopore reads (default mode)

Place all FASTQ/FASTQ.GZ files in your input folder and run:

```bash
nextflow run main.nf --input_dir /path/to/reads --output_dir /path/to/results --assembler autocycler -resume
```

The pipeline will:
 - Perform QC and adapter trimming using Porechop
 - Assemble reads using the chosen assembler
 - Run QUAST on the assembled genomes

### 2. Run with pre-assembled genomes (FASTA input)

If assemblies are already available, you can skip the read processing steps by providing the `--assemblies` option:

```bash
nextflow run main.nf --assemblies /path/to/assemblies --output_dir /path/to/results -resume
```

## 🧩 Pipeline Steps

1. **Input Handling:**  
   The pipeline automatically detects whether the user has provided:
   - Raw Nanopore reads (`--input_dir`, default), or  
   - Pre-assembled genomes (`--assemblies`)  

   If both are given, the pipeline will prioritise **assemblies**.

2. **Quality Control & Trimming:**  
   When FASTQ reads are used as input, they are processed using **Porechop** to remove adapters and low-quality regions.

3. **Assembly:**  
   Trimmed reads are assembled using the user-specified assembler (`--assembler`), which can be:
   - **Autocycler** – for hybrid and circular bacterial genome assembly  
   - **Dragonflye** – for long-read-only assembly and polishing  

4. **Post-assembly Evaluation:**  
   All assemblies (from FASTQ or FASTA input) are evaluated using **QUAST** and other downstream tools.

5. **Plasmid Extraction:**  
   Every contig that is **circular** (`circular=true`, or `circular=Y` from Dragonflye) and **≥ 1 kb and < 500 kb** is written to its own FASTA file in `assemblies/plasmids/`, numbered in assembly order: isolate `AUSMDU00123` gives `AUSMDU00123.p1.fasta`, `AUSMDU00123.p2.fasta`, … Each header becomes `>AUSMDU00123.p1` followed by the original header, and `AUSMDU00123_plasmids.tsv` lists every extracted plasmid with its source contig and length. Change the size limits with `--plasmid_min_length` and `--plasmid_max_length`.

   The extracted plasmids are then analysed on their own. All plasmids from one isolate are combined into a single FASTA, and each result row is labelled with its plasmid ID (e.g. `AUSMDU00123.p1`):
   - **AMRFinderPlus** → `plasmid_amrfinder_results/<isolate>_plasmids_amrfinder.tsv` (the `Contig id` column is the plasmid ID)
   - **MOB-typer** (`mob_typer --multi`) → `plasmid_mobtyper_results/<isolate>_plasmids_mobtyper.tsv`: replicon, relaxase and MPF types, predicted mobility and MOB cluster per plasmid (the `sample_id` column is the plasmid ID)

   Isolates with no extracted plasmids are skipped.

6. **AMRFinder Analysis:**  
   Detection of antimicrobial resistance (AMR) genes using [NCBI AMRFinderPlus](https://github.com/ncbi/amr).  
   The results include identified resistance genes, their drug classes, and associated gene families.

7. **MOB-suite Analysis:**  
   Comprehensive plasmid typing and reconstruction using [MOB-suite](https://github.com/phac-nml/mob-suite).  
   This step performs:
   - Plasmid clustering and separation from chromosomal contigs  
   - Replicon typing and relaxase identification  
   - Mobility classification (MOB, CONJ, or non-mobilisable)  
   - Prediction of plasmid transmissibility and host range.

8. **PlasmidFinder Analysis:**  
   Detection of plasmid replicon markers using [PlasmidFinder](https://bitbucket.org/genomicepidemiology/plasmidfinder/src/master/).  
   The tool identifies incompatibility groups (Inc types) and provides replicon-based classification for detected plasmids.


