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

5. **AMRFinder Analysis:**  
   Detection of antimicrobial resistance (AMR) genes using [NCBI AMRFinderPlus](https://github.com/ncbi/amr).  
   The results include identified resistance genes, their drug classes, and associated gene families.

6. **MOB-suite Analysis:**  
   Comprehensive plasmid typing and reconstruction using [MOB-suite](https://github.com/phac-nml/mob-suite).  
   This step performs:
   - Plasmid clustering and separation from chromosomal contigs  
   - Replicon typing and relaxase identification  
   - Mobility classification (MOB, CONJ, or non-mobilisable)  
   - Prediction of plasmid transmissibility and host range.

7. **PlasmidFinder Analysis:**  
   Detection of plasmid replicon markers using [PlasmidFinder](https://bitbucket.org/genomicepidemiology/plasmidfinder/src/master/).  
   The tool identifies incompatibility groups (Inc types) and provides replicon-based classification for detected plasmids.


