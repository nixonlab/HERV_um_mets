# Snakemake workflow

## Title: Extracting HERV Expression Uveal Melanoma Datasets

Bulk RNA-Seq Telescope analysis of TCGA primary uveal melanoma samples, MSKCC metastatic uveal melanoma samples, and Nilsson metastatic melanoma samples (restricted access)

## Dataset Citations

### TCGA citation
Robertson, A. G., et al. (2017). "Integrative Analysis Identifies Four Molecular and Clinical Subsets in Uveal Melanoma." Cancer Cell 32(2): 204-220.e215.

### MSKCC citation
Kraehenbuehl, L., et al. (2022). "Pilot Trial of Arginine Deprivation Plus Nivolumab and Ipilimumab in Patients with Metastatic Uveal Melanoma." Cancers (Basel) 14(11).

### Nilsson citation
Karlsson, J., et al. (2020). "Molecular profiling of driver events in metastatic uveal melanoma." Nat Commun 11(1): 1894.

## Workflow Graphs

### To get DAG:

snakemake --profile profiles/aws  --forceall --dag | dot -Tpdf > dag.pdf  

### To get rule graph:

snakemake --profile profiles/aws  --forceall --rulegraph | dot -Tpdf > rulegraph.pdf  

### To get file graph:

snakemake --profile profiles/aws  --forceall --filegraph | dot -Tpdf > filegraph.pdf  

### To run pipeline:

snakemake --profile profiles/aws/ all

### To modify pipeline:

Change sample download table and method. This pipeline uses different methods to download files.

TCGA: curl
EGA (Nilsson): pyega3
MSK: already obtained from collaboration with MSK IMPACT project

## Usage

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this (original) repository: https://github.com/nixonlab/HERV_um_mets