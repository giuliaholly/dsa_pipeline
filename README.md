# DSA Pipeline

A Nextflow pipeline for personalized reference construction from the Human Pangenome and somatic variant discovery in Oxford Nanopore Technologies (ONT) tumor sequencing data.

## Overview

The Pipeline builds a sample-specific diploid reference genome, or donor-specific assembly (DSA), from the Human Pangenome and performs alignment, SNV calling, SV calling, annotation, and prioritization of somatic variants.

The workflow is designed for long-read ONT tumor sequencing datasets and supports both BAM and FASTQ input files.

Current features include:

* Construction of personalized diploid references from the Human Pangenome
* Read alignment against personalized references
* SNV calling
* SV calling
* Liftover of variants from personalized references to GRCh38 using VarBridge (https://github.com/tobiasrausch/VarBridge)
* Somatic variant filtering
* Variant annotation using Ensembl VEP
* Optional gene-based prioritization using a user-provided gene list
* Multi-sample processing

Tumor-only mode is currently supported.

Tumor-normal mode is under active development. The planned workflow will generate the personalized reference from the matched normal sample and perform paired somatic variant calling.

---

## Execution environments

Supported profiles:

* `local`
* `slurm` (recommended)

---

## Initial Setup

Create a Singularity cache directory:

```bash
mkdir cache
```

Download required containers and resources:

```bash
singularity pull docker://nanozoo/minimap2

singularity pull docker://hkubal/clairs-to

singularity pull docker://google/deepsomatic:1.10.0

singularity pull docker://eichlerlab/severus:1.6.1

singularity pull docker://ensemblorg/ensembl-vep

wget https://github.com/refresh-bio/KMC/releases/download/v3.2.4/KMC3.2.4.linux.arm64.tar.gz

wget https://github.com/vgteam/vg/releases/latest

wget https://github.com/tobiasrausch/VarBridge/releases/download/v0.1.8/varbridge-v0.1.8-linux-amd64

chmod +x varbridge-v0.1.8-linux-amd64

singularity pull docker://dellytools/delly:v2.1.0

wget https://human-pangenomics.s3.amazonaws.com/pangenomes/freeze/release2/minigraph-cactus/hprc-v2.0-mc-chm13.gbz

vg index -t 10 -j hprc-v1.1-mc-chm13.dist \
    --no-nested-distance \
    hprc-v1.1-mc-chm13.gbz

vg gbwt -p \
    --num-threads 10 \
    -r hprc-v1.1-mc-chm13.ri \
    -Z hprc-v1.1-mc-chm13.gbz

vg haplotypes \
    -v 2 \
    -t 10 \
    -H hprc-v1.1-mc-chm13.hapl \
    hprc-v1.1-mc-chm13.gbz

cp /g/solexa/bin/software/kent/bin/x86_64/faSplit ${SINGULARITY_CACHE}

cp /g/solexa/bin/software/kent/bin/x86_64/faCount ${SINGULARITY_CACHE}

cp /scratch/olivucci/leukemia/findTandemRepeats ${SINGULARITY_CACHE}

```

---

## Requirments

Inside the working directory, either:

### Option 1

Use the provided `Makefile`:

```bash
make all
```

### Option 2

Create a Conda environment manually containing:

* nextflow
* pysam
* sansa=0.2.5
* bcftools

---

## Installation

Clone the repository:

```bash
git clone https://github.com/giuliaholly/dsa_pipeline.git
```

---

## Input

Input samples must be provided through a tab-separated CSV file with the following header:

```text
sample  tumor  normal
```

Example:

```text
sample  tumor  normal
PAT001  /data/PAT001_tumor.bam  /data/PAT001_normal.bam
PAT002  /data/PAT002_tumor.fastq.gz  /data/PAT002_normal.fastq.gz
```

### Columns

| Column | Description                              |
| ------ | ---------------------------------------- |
| sample | Sample identifier                        |
| tumor  | Path to tumor BAM or FASTQ file          |
| normal | Path to matched normal BAM or FASTQ file |

Notes:

* BAM and FASTQ inputs are supported.
* ONT data only.
* Multiple samples can be processed simultaneously by adding one sample per row.
* In tumor-only mode, just leave the "normal" column empty.

---

## Environment Variables

Before launching the pipeline:

```bash
WORK_DIR="/path/to/work/dir"

SINGULARITY_CACHE="/path/to/singularity/cache/dir"

REFERENCE_DIR="/path/to/reference/dir"

VEP_CACHE="/path/to/ensembl-vep/cache/dir"

TS=$(date +%Y%m%d_%H%M%S)

export TMPDIR="${WORK_DIR}/tmp"

mkdir -p $TMPDIR

export NXF_TEMP="${WORK_DIR}/tmp"

export APPTAINER_TMPDIR="${WORK_DIR}/tmp"

export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHE}"

export PATH="${WORK_DIR}/mamba/bin:${PATH}"
```

---

## Running the Pipeline

Example SLURM execution:

```bash
nextflow run dsa_pipeline/main.nf \
    --run pipeline \
    --timestamp $TS \
    --samplesheet ${WORK_DIR}/samplesheet.csv \
    --output_dir ${WORK_DIR}/results \
    -c dsa_pipeline/nextflow.config \
    -profile slurm \
    --singularity_cache ${SINGULARITY_CACHE} \
    --tmp_dir ${WORK_DIR}/tmp \
    --vep_cache ${VEP_CACHE} \
    --GRCh38 /path/to/reference/GRCh38.fa \
    --CHM13 /path/to/reference/CHM13.fa \
    --genes ${WORK_DIR}/genes.txt \
    --work_dir ${WORK_DIR} \
    --bind_path ${WORK_DIR},${SINGULARITY_CACHE},${REFERENCE_DIR},${VEP_CACHE}
```

---

## Parameters

| Parameter             | Description                                   |
| --------------------- | --------------------------------------------- |
| `--run`               | Workflow mode (`pipeline`)                    |
| `--timestamp`         | Execution timestamp                           |
| `--samplesheet`       | Input sample sheet                            |
| `--output_dir`        | Output directory                              |
| `--singularity_cache` | Singularity/Apptainer cache directory         |
| `--tmp_dir`           | Temporary directory                           |
| `--vep_cache`         | Ensembl VEP cache directory                   |
| `--GRCh38`            | Path to GRCh38 reference FASTA                |
| `--CHM13`             | Path to CHM13 reference FASTA                 |
| `--genes`             | Optional gene list for variant prioritization |
| `--work_dir`          | Working directory                             |
| `--bind_path`         | Paths mounted inside containers               |

---

## Outputs

Results are written to:

```text
output_dir/
└── SAMPLE_NAME/
```

Each sample directory contains intermediate and final outputs.

Important results are located in:

```text
output_dir/SAMPLE_NAME/varbridge/
```

This directory contains:

* Lifted variants in GRCh38 coordinates
* Somatic-filtered variants
* VEP-annotated variants
* Gene-prioritized variants (if `--genes` is provided)

---

## Gene Prioritization

If a gene list is provided using:

```bash
--genes genes.txt
```

the pipeline will retain annotated variants affecting genes present in the supplied file.

One gene symbol per line is expected.

Example:

```text
TP53
FLT3
NPM1
RUNX1
DNMT3A
```

---

## Current Status

### Supported

* ONT BAM input
* ONT FASTQ input
* Tumor-only analysis
* Multi-sample processing
* Personalized reference generation
* SNV calling
* SV calling
* VEP annotation
* Gene panel prioritization

### In Development

* Matched tumor-normal analysis
* Somatic paired calling using tumor/normal personalized references
* Karyotype analysis/CNV calling

---

## References

### Human Pangenome

https://humanpangenome.org

### VarBridge

https://github.com/tobiasrausch/VarBridge

### Ensembl VEP

https://www.ensembl.org/info/docs/tools/vep/index.html

### Nextflow

https://www.nextflow.io
