
rule download_bam_tcga:
    # download BAM from GDC for TCGA data
    input:
        config['GDC_token']
    output:
        temp('results/original_bam/{gdc_id}')
    params:
        uuid = lambda wc: gdc_file.loc[wc.gdc_id]['Sample ID'],
        md5sum = lambda wc: gdc_file.loc[wc.gdc_id]['md5sum']
    wildcard_constraints:
        gdc_id = "TCGA\\-..\\-[A-Z]...\\-[0-9]{2}[A-Z]"
    shell:
        '''
mkdir -p $(dirname {output[0]})
curl\
 -H "X-Auth-Token: $({input[0]})"\
 https://api.gdc.cancer.gov/data/{params.uuid}\
 > {output[0]}
echo {params.md5sum} {output[0]} | md5sum -c -
chmod 600 {output[0]}
        '''

# Default SAM attributes cleared by RevertSam
attr_revertsam = ['NM', 'UQ', 'PG', 'MD', 'MQ', 'SA', 'MC', 'AS']
# SAM attributes output by STAR
attr_star = ['NH', 'HI', 'NM', 'MD', 'AS', 'nM', 'jM', 'jI', 'XS', 'uT']
# Additional attributes to clear
ALN_ATTRIBUTES = list(set(attr_star) - set(attr_revertsam))

rule revert_and_mark_adapters:
    """ Create unmapped BAM (uBAM) from aligned BAM
    """
    input:
        "results/original_bam/{gdc_id}"
    output:
        protected("results/ubam/{gdc_id}.bam")
    log:
        "results/ubam/{gdc_id}.revert_bam.log"
    wildcard_constraints:
        gdc_id = "TCGA\\-..\\-[A-Z]...\\-[0-9]{2}[A-Z]"
    conda:
        "envs/utils.yaml"
    params:
        attr_to_clear = expand("--ATTRIBUTE_TO_CLEAR {a}", a=ALN_ATTRIBUTES),
        tmpdir = config['local_tmp']
    shell:
        '''
picard RevertSam\
 -I {input[0]}\
 -O {output[0]}\
 --SANITIZE true\
 --COMPRESSION_LEVEL 0\
 --VALIDATION_STRINGENCY SILENT\
 {params.attr_to_clear}\
 --TMP_DIR {params.tmpdir}\
 2> {log[0]}\
chmod 600 {output[0]}
        '''

localrules: make_tcga_ubams
rule make_tcga_ubams:
    input:
        expand("results/ubam/{sample_id}.bam", sample_id=tcga_samples)