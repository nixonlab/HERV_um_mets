#!/usr/bin/env python
# -*- coding: utf-8 -*-

from glob import glob

# msk_samples is from common.smk

msk_dirs = {k:glob('raw/*%s*' % k) for k in msk_samples}
assert all(len(v)==1 for v in msk_dirs.values())
msk_dirs = {k:v[0] for k,v in msk_dirs.items()}

msk_runs = {}
for s in msk_samples:
    msk_runs[s] = sorted(glob('%s/%s.L00?.unaligned.bam' % (msk_dirs[s], s)))


def msk_run_ubams(wc):
    return msk_runs[wc.sample_id]


rule merge_run_ubam:
    input:
        msk_run_ubams
    output:
        "results/ubam/{sample_id}.bam"
    params:
        rawdir = lambda wc: msk_dirs[wc.sample_id]
    conda:
        "../envs/utils.yaml"
    shell:
        '''
samtools view --no-PG -H {input[0]} | grep -v '^@RG' > {params.rawdir}/header.sam
for f in {input}; do
    samtools view --no-PG -H $f | grep '^@RG' >> {params.rawdir}/header.sam
done

samtools cat -H {params.rawdir}/header.sam -o {output} {input}
        '''


