#! /usr/bin/env python
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

samples = pd.DataFrame(
        {'sample_id': msk_samples,}
    ).set_index("sample_id", drop=False)

# samples = (
#     pd.read_csv(
#         config['samples'],
#         sep="\t",
#         dtype={
#           'sample_id': str,
#           'file_name': str,
#           'md5sum': str,
#           'file_size': int,
#           'object_id': str,
#         },
#         comment="#",
#     )
#     .set_index("sample_id", drop=False)
#     .sort_index()
# )

# def object_id_from_file_name(wc):
#     row = samples.loc[samples['file_name'] == wc.file_name]
#     return row['object_id'].values[0].split('/')[1]
