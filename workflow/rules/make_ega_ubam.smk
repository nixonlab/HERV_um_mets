#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" Download file from EGA
Each EGA file corresponds to one FASTQ file so a paired end run is comprised of two files.
The downloader `pyega3` requires the file ID with the format "EGAFXXXXXXXXXXX" and the
path for the credentials file. The name of the downloaded file is contained in metadata
file "Sample_File.map" and we symlink this to the output path.
"""
localrules: download_ega
rule download_ega:
    output:
        'raw/EGA/{egaf_id}/reads.fastq.gz'
    params:
        cred = config['ega_credentials'],
        basename = lambda wc: re.sub(r'\.cip$', '', ega_files.loc[wc.egaf_id, 'FILE_NAME'])        
    wildcard_constraints:
        egaf_id = "EGAF\d+"
    conda:
        "../envs/pyega.yaml"  
    shell:
        '''
pyega3 -c 5 -cf  {params.cred} fetch --output-dir raw/EGA {wildcards.egaf_id}
echo "$(cat raw/EGA/{wildcards.egaf_id}/{params.basename}.md5)  raw/EGA/{wildcards.egaf_id}/{params.basename}" | md5sum -c && ln -s {params.basename} {output[0]}
        '''


""" Run-level uBAM
Convert R1 and R2 FASTQ files from one run into unaligned BAM (uBAM)
"""
def make_ega_run_ubam_input(wc):
    row = ega_runs.loc[wc.egan_id,]
    return ['raw/EGA/%s/reads.fastq.gz' % row['FILE_ACC_R1'], 'raw/EGA/%s/reads.fastq.gz' % row['FILE_ACC_R2'] ]

localrules: make_ega_run_ubam
rule make_ega_run_ubam:
    input:
        make_ega_run_ubam_input
    output:
        temp('raw/{egan_id}.unaligned.bam')
    params:
        sample = lambda wc: ega_run_sample_map[wc.egan_id]
    log:
        'raw/{egan_id}.unaligned.bam.log'
    conda:
        "../envs/utils.yaml"
    shell:
        '''
picard FastqToSam -F1 {input[0]} -F2 {input[1]} -O {output[0]} -SO unsorted -SM {params.sample} -RG {wildcards.egan_id} &> {log[0]}
        '''


""" Sample-level uBAM
Concatenate run-level uBAMs into sample-level uBAM.
EGA sample names begin with "UM"
"""
def make_ega_sample_ubam_input(wc):
    runs = ega_sample_meta.loc[wc.sample_id, 'RUN_ACCESSION'].split(',')
    return expand('raw/{egan_id}.unaligned.bam', egan_id=runs)

localrules: make_ega_sample_ubam
rule make_ega_sample_ubam:
    input:
        make_ega_sample_ubam_input
    output:
        "results/ubam/{sample_id}.bam"
    wildcard_constraints:
        sample_id = "UM\d+(_\w+)?"
    conda:
        "../envs/utils.yaml"
    shell:
        '''
samtools view --no-PG -H {input[0]} | grep -v '^@RG' > {output[0]}.header.sam
for f in {input}; do
    samtools view --no-PG -H $f | grep '^@RG' >> {output[0]}.header.sam
done

samtools cat -h {output[0]}.header.sam -o {output[0]} {input}
rm -f {output[0]}.header.sam
        '''


""" Make all EGA uBAMs
"""
localrules: make_ega_ubams
rule make_ega_ubams:
    input:
        expand("results/ubam/{sample_id}.bam", sample_id=ega_samples)
