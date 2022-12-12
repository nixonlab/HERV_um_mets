#!/usr/bin/env python
# -*- coding: utf-8 -*-

def object_id_from_file_name(wc):
    row = samples.loc[samples['filename'] == wc.filename]
    return {
        'obj_id': row['id'].values[0].split('/')[1],
        'md5sum': row['md5'].values[0],
    }

rule download_bam_gtex:
    output:
        temp('results/original_bam/{filename}')
    params:
        object_id_from_file_name,
    shell:
        '''
resources/gen3-client download-single\
  --no-prompt\
  --skip-completed\
  --profile=bendall\
  --protocol=s3\
  --download-path results/original_bam\
  --guid={params[0][obj_id]}
  
echo "{params[0][md5sum]}  {output[0]}" | md5sum -c -
        '''

def original_bam_from_sample_id(wc):
    row = samples.loc[wc.sample_id]
    return os.path.join('results', 'original_bam', row['file_name'])


# Default SAM attributes cleared by RevertSam
attr_revertsam = ['NM', 'UQ', 'PG', 'MD', 'MQ', 'SA', 'MC', 'AS']
# SAM attributes output by STAR
attr_add = ['nM', 'NH', 'ch', 'XS', 'HI', 'uT', ]
# {'NM', 'nM', 'AS', 'NH', 'ch', 'RG', 'XS', 'HI', 'uT', 'SA'}
# {'NM', 'nM', 'AS', 'NH', 'ch', 'RG', 'XS', 'HI', 'uT', 'SA'}

# Additional attributes to clear
ALN_ATTRIBUTES = list(set(attr_add) - set(attr_revertsam))


rule original_bam_to_ubam:
    input:
        original_bam_from_sample_id
    output:
        'results/ubam/{sample_id}.bam'
    log:
        "logs/revert_bam.{sample_id}.log",
        "logs/mark_adapters.{sample_id}.log",
        "logs/mark_adapters.{sample_id}.metrics"
    conda:
        "../envs/picard.yaml"
    params:
        attr_to_clear = expand("--ATTRIBUTE_TO_CLEAR {a}", a=ALN_ATTRIBUTES)
    shell:
       '''
picard RevertSam\
  -I {input[0]}\
  -O /dev/stdout\
  --SANITIZE true\
  --COMPRESSION_LEVEL 0\
  --VALIDATION_STRINGENCY SILENT\
  --TMP_DIR {config[tmpdir]}\
  {params.attr_to_clear}\
  2> {log[0]} | \
picard MarkIlluminaAdapters\
  -I /dev/stdin\
  -O {output[0]}\
  -M {log[2]}\
  --COMPRESSION_LEVEL 5\
  --TMP_DIR {config[tmpdir]}\
  2> {log[1]}

chmod 660 {output[0]}
        '''

rule archive_ubam:
    input:
        "results/ubam/{sample_id}.bam"
    output:
        "efs_results/{sample_id}/unaligned.bam"
    shell:
        '''
mv {input} {output}
        '''
