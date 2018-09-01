rule all:
    input:
        auspice_tree = "auspice/mers-beast-tutorial_tree.json",
        auspice_meta = "auspice/mers-beast-tutorial_meta.json"

rule files:
    params:
        input_alignment = "data/MERS_CoV_274_CDS.fasta",
        input_tree = "data/MERS_CoV_274_mcc.tree",
        input_metadata = "data/MERS_CoV_274_metadata.tsv",
        colors = "config/colors.tsv",
        auspice_config = "config/auspice_config.json"

files = rules.files.params

rule tree:
    message: "Converting BEAST MCC tree to simple Newick tree"
    input:
        alignment = files.input_tree
    output:
        tree = "results/tree_raw.nwk"
    shell:
        """
        ruby scripts/convert-beast-tree-to-newick.rb data/MERS_CoV_274_mcc.tree > results/tree_raw.nwk
        """

rule refine:
    message:
        """
        Refining tree
          - keep BEAST branch lengths as timetree
        """
    input:
        tree = rules.tree.output.tree,
        alignment = files.input_alignment,
        metadata = files.input_metadata
    output:
        tree = "results/tree.nwk",
        node_data = "results/branch_lengths.json"
    shell:
        """
        augur refine \
            --tree {input.tree} \
            --alignment {input.alignment} \
            --metadata {input.metadata} \
            --output-tree {output.tree} \
            --output-node-data {output.node_data}
        """

rule export:
    message: "Exporting data files for auspice"
    input:
        tree = rules.refine.output.tree,
        metadata = files.input_metadata,
        branch_lengths = rules.refine.output.node_data,
        colors = files.colors,
        auspice_config = files.auspice_config
    output:
        auspice_tree = rules.all.input.auspice_tree,
        auspice_meta = rules.all.input.auspice_meta
    shell:
        """
        augur export \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --node-data {input.branch_lengths} \
            --colors {input.colors} \
            --panels tree \
            --extra-traits host \
            --auspice-config {input.auspice_config} \
            --output-tree {output.auspice_tree} \
            --output-meta {output.auspice_meta}
        """

rule clean:
    message: "Removing directories: {params}"
    params:
        "results ",
        "auspice"
    shell:
        "rm -rfv {params}"
