

rule all:
    input:
        # The first rule should define the default target files
        # Subsequent target rules can be specified below. They should start with all_*.


rule all_alignments:
    input:
        stockholm_file=config['stockholm_file'],
        tarbal= config['tarbal']


include: 'rules/alignment.smk'
include: 'rules/mmseqs.smk'
