#! /usr/bin/env python
# -*- coding: utf-8 -*-

""" Parsing MSK samples information
"""
msk_runs = pd.read_csv('resources/mskruns.txt', sep='\t', header=None, 
                       names=['SAMPLE_ID', 'LANE', 'R1_PATH', 'R2_PATH', 'RUN_DIR'])
msk_clin = pd.read_csv('resources/hg_19010_clin.csv').sort_values(by='SK-MEL')
msk_samples = sorted(msk_runs['SAMPLE_ID'].unique().tolist())

assert msk_samples == msk_clin['SK-MEL'].tolist()

msk_sample_meta = {'SAMPLE_ID': [], 'RUN_UBAM': [], }
for s in msk_samples:
    run_paths = []
    for i,row in (msk_runs.loc[msk_runs['SAMPLE_ID'] == s,]).sort_values(by='LANE').iterrows():
        run_paths.append('%s/%s.%s.unaligned.bam' % (row.loc['RUN_DIR',], row.loc['SAMPLE_ID',], row.loc['LANE',]))
    msk_sample_meta['SAMPLE_ID'].append(s)
    msk_sample_meta['RUN_UBAM'].append(','.join(run_paths))

msk_sample_meta = pd.concat([pd.DataFrame(msk_sample_meta), msk_clin], axis=1).set_index('SAMPLE_ID')

""" Parsing EGA samples information
"""
ega_files = (pd.read_csv('resources/EGAD00001006031.files.tsv', sep='\t')).set_index("FILE_ACCESSION")
ega_runs = (pd.read_csv('resources/EGAD00001006031.runs.tsv', sep='\t')).set_index("SAMPLE_ACCESSION")
ega_sample_meta = (pd.read_csv('resources/EGAD00001006031.samples_metadata.tsv', sep='\t')).set_index('SAMPLE_ID')

ega_samples = ega_sample_meta.index.tolist()


ega_run_sample_map = {}
for samp_id,row in ega_sample_meta.iterrows():
    for runid in row['RUN_ACCESSION'].split(','):
        ega_run_sample_map[runid] = samp_id

""" All samples """
samples = pd.DataFrame(
        {'sample_id': msk_samples + ega_samples}
    ).set_index("sample_id", drop=False)
