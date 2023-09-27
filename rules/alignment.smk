import os

fasta_folder= config['in_dir']

IDs, = glob_wildcards(f'{fasta_folder}/{{cluster_id}}.fasta')


rule align:
    input:
        f'{fasta_folder}/{{cluster_id}}.fasta'
    output:
        temp(f'alignments/{taxid}/{{cluster_id}}.mfa')
    conda:
        'envs/alignment.yaml'
    threads: 6
    params: # this should ho in the config or so
        extra=[f'--{option}' for option in config['mafft_options']]
    shell:
        'mafft --thread {threads} {params.extra} {input} > {output}'

aligned_file=rules.align.output

if config['trim']:

    rule trim:
        input:
            '{fastafile}.mfa'
        output:
            '{fastafile}.trim.mfa'
        conda:
            'envs/alignment.yaml'
        params: # this should ho in the config or so
            params= [f'-{key} {value}' for key,value in config['trimal'].items()]
        threads: 1
        shell:
            'trimal -in {input} -out {output}'
            ' {params.params} '

    aligned_file=rules.trim.output


localrules: MSAfasta_to_stockholm,make_tarbal
rule MSAfasta_to_stockholm:
    input:
        alignment_files= expand(cluster_id=IDs)
    output:
        stockholm_file= temp(config['output_file'])
    params:
        family_ids= IDs
    conda:
        'envs/alignment.yaml'
    threads:
        1
    script:
        "scripts/faMSA_to_StockholmMSA.py"


rule make_tarbal:
    input:
        alignment_files= expand(rules.align.output,
                                cluster_id=IDs,
                                ),
        stockholm_file=config['stockholm_file']
    output:
        config['tarbal']
    params:
        dir= lambda wc,input: os.path.dirname(input.alignment_files[0])
    shell:
        """
            tar -czf {output} {params.dir}
        """
