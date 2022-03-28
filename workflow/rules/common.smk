#! /usr/bin/env python
# -*- coding: utf-8 -*-


samples = (
    pd.read_csv(
        config['samples'],
        sep="\t",
        dtype={
          'sample_id': str,
          'file_name': str,
          'md5sum': str,
          'file_size': int,
          'object_id': str,
        },
        comment="#",
    )
    .set_index("sample_id", drop=False)
    .sort_index()
)

# def object_id_from_file_name(wc):
#     row = samples.loc[samples['file_name'] == wc.file_name]
#     return row['object_id'].values[0].split('/')[1]
