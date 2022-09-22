#!/usr/bin/env python
# -*- coding: utf-8 -*-

""" Run-level uBAM
Convert R1 and R2 FASTQ files from one run into unaligned BAM (uBAM)
"""
def make_msk_run_ubam_input(wc):
    m = msk_runs.loc[(msk_runs['SAMPLE_ID'] == wc.sample_id) & (msk_runs['LANE'] == wc.lane), ]
    assert len(m.index) == 1, 'wrong number of rows returned'
    return m['R1_PATH'].item(), m['R2_PATH'].item()

localrules: make_msk_run_ubam
rule make_msk_run_ubam:
    input:
        make_msk_run_ubam_input
    output:
        temp('raw/{run_dir}/{sample_id}.{lane}.unaligned.bam')
    wildcard_constraints:
        run_dir = "\w+",
        sample_id = "SK_MEL_\d{4}[AB]_T",
        lane = 'L00[012]'        
    log:
        'raw/{run_dir}/{sample_id}.{lane}.unaligned.bam.log'
    conda:
        "../envs/utils.yaml"
    shell:
        '''
picard FastqToSam -F1 {input[0]} -F2 {input[1]} -O {output[0]} -SO unsorted -SM {wildcards.sample_id} -RG {wildcards.sample_id}.{wildcards.lane} &> {log[0]}
        '''


""" Sample-level uBAM
Concatenate run-level uBAMs into sample-level uBAM.
MSK sample names have the format "SK_MEL_\d{4}[AB]_T"
"""
def make_msk_sample_ubam_input(wc):
    runs = msk_sample_meta.loc[wc.sample_id, 'RUN_UBAM'].split(',')
    return runs

localrules: make_msk_sample_ubam
rule make_msk_sample_ubam:
    input:
        make_msk_sample_ubam_input
    output:
        temp("results/ubam/{sample_id}.bam")
    wildcard_constraints:
        sample_id = "SK_MEL_\d{4}[AB]_T"
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


""" Make all MSK uBAMs
"""
localrules: make_msk_ubams
rule make_msk_ubams:
    input:
        expand("results/ubam/{sample_id}.bam", sample_id=msk_samples)
