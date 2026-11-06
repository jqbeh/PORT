# Installation
PORT can be installed by cloning the Github repository and setting up the profiles using Nextflow.

Before cloning the repository, make sure you have [Docker](https://www.docker.com/) installed and running.

Install [Nextflow](https://www.nextflow.io/) if you haven't already:

```bash
curl -s https://get.nextflow.io | bash
```

Clone the repository:

```bash
git clone https://github.com/immem-hackathon-2025/PORT.git
cd PORT
```

## 📦 Install with conda

PORT can be installed as a single `port` command, which brings Nextflow and Java with it:

```bash
conda install -c conda-forge -c bioconda port      # or: mamba install ...
port --version
port --assemblies /path/to/assemblies --output_dir /path/to/results -resume
```

`port` accepts every pipeline and Nextflow option (`--clustering pling`, `-profile conda`, `-resume`, ...). The analysis tools still run in Docker by default, so Docker must be installed and running. Alternatively, use `-profile conda` with the `port_env` environment described below.

The pipeline files are installed in `$CONDA_PREFIX/share/port`. A downloaded Bakta database is kept in `~/.port/databases/bakta` (change with `--bakta_db_cache`).

### Building the conda package (maintainers)

The recipe is in `conda-recipe/`. To release a new version:

1. Bump `version` in `nextflow.config` and `conda-recipe/meta.yaml`, then tag the release on GitHub (e.g. `v1.1.0`).
2. Put the tarball's checksum in `meta.yaml`: `curl -sL https://github.com/jqbeh/PORT/archive/refs/tags/v1.1.0.tar.gz | sha256sum`
3. Test locally: `conda build -c conda-forge -c bioconda conda-recipe/`
4. Publish by copying `conda-recipe/` to `recipes/port/` in a fork of [bioconda-recipes](https://github.com/bioconda/bioconda-recipes) and opening a PR, or by uploading the build to your own anaconda.org channel with `anaconda upload`.

## ⚙️ Setting Up Profiles

This pipeline supports two execution profiles — **Docker** (default) and **Conda**.  
The behavior depends on whether you specify the `-profile` option when running Nextflow.

### Docker (default)

🐳 Default: Docker Profile (No `-profile` specified)

If you **do not specify any profile**, Nextflow will use the **default `standard` (Docker)** profile.

In this mode:
- All required tools are pulled automatically from pre-built Docker containers.
- No local setup or Conda environment is required.
- The first run will take longer because Nextflow downloads the container images.

```bash
nextflow run main.nf --input_dir input_folder --output_dir output_folder
```

### Conda

After cloning the Github repository, run:

1. Create and activate the environment:
```bash
#create conda env
cd PORT 
conda env create -f envs/environment.yml -y
#activate the env
conda activate port_env
```

2. Then run the pipeline by specifying `--profile`:
```bash
nextflow run main.nf --assemblies /path/to/assemblies/ --output_dir /path/to/results -resume --read_type ont_r9 -profile conda
```

If you aleady have an existing conda environment, you can specify the name of the conda env using `--conda_env`:
```bash
nextflow run main.nf --assemblies /path/to/assemblies/ --output_dir /path/to/results -resume -profile conda --conda_env my_env
```

## Dependencies

Required:
#### Nextflow
  - nextflow>=22.10.6

#### Assembly and processing tools
  - autocycler>=0.5.0            # https://github.com/rrwick/Autocycler
  - canu>=2.3                    # https://github.com/marbl/canu
  - flye>=2.9.6                  # https://github.com/mikolmogorov/Flye
  - metamdbg>=1.0                # https://github.com/GaetanBenoitDev/metaMDBG
  - miniasm>=0.3                 # https://github.com/lh3/miniasm
  - minimap2>=2.28               # https://github.com/lh3/minimap2
  - minipolish>=0.2.0            # https://github.com/rrwick/Minipolish
  - myloasm>=0.1.0               # https://github.com/bluenote-1577/myloasm
  - necat>=0.0.1_update20200803  # https://github.com/xiaochuanle/NECAT
  - nextdenovo>=2.5.2            # https://github.com/Nextomics/NextDenovo
  - nextpolish>=1.4.1            # https://github.com/Nextomics/NextPolish
  - plassembler>=1.8.0           # https://github.com/gbouras13/plassembler
  - racon>=1.5.0                 # https://github.com/lbcb-sci/racon
  - raven-assembler>=1.8.3       # https://github.com/lbcb-sci/raven
  - wtdbg>=2.5                   # https://github.com/ruanjue/wtdbg2
  - porechop>=0.2.4              # https://github.com/rrwick/Porechop
  - nanoplot>=1.46.1             # https://github.com/wdecoster/NanoPlot
  - medaka>=2.1.1                # https://github.com/nanoporetech/medaka
  - dragonflye>=1.2.1            # https://github.com/rpetit3/dragonflye

#### AMR and plasmid typing
  - ncbi-amrfinderplus>=4.0.23  # https://github.com/ncbi/amr
  - mob_suite>=3.1.9            # https://github.com/phac-nml/mob-suite
  - plasmidfinder>=2.1.6        # https://bitbucket.org/genomicepidemiology/plasmidfinder/src/master/

#### Assembly evaluation
  - quast>=5.3.0               #https://github.com/ablab/quast


