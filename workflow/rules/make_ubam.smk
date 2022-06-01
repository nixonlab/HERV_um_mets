#!/usr/bin/env python
# -*- coding: utf-8 -*-

msk_samples = [
    'SK_MEL_1316A_T',
    'SK_MEL_1313A_T',
    'SK_MEL_1299A_T',
    'SK_MEL_1331A_T',
    'SK_MEL_1058B_T',
    'SK_MEL_1327A_T',
    'SK_MEL_1330A_T',
    'SK_MEL_1306B_T',
    'SK_MEL_1306A_T',
    'SK_MEL_1313B_T',
    'SK_MEL_1331B_T',
    'SK_MEL_1299B_T',
    'SK_MEL_1328A_T',
    'SK_MEL_1327B_T',
    'SK_MEL_1330B_T',
]
msk_dirs = {k:glob('raw/*%s*' % k) for k in msk_samples}
assert all(len(v)==1 for v in msk_dirs.values())
msk_dirs = {k:v[0] for k,v in msk_dirs.items()}

msk_runs = {s:glob('%s/%s.L00?.unaligned.bam' % (msk_dirs[s], s)) for s in msk_samples}


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
        '''
