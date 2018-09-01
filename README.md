# MERS / BEAST to Nextstrain tutorial

This is a tutorial that imports BEAST tree from [Dudas et al. 2018](https://bedford.io/papers/dudas-mers-structure/) analysis of MERS-CoV spillover and converts to an [auspice](https://github.com/nextstrain/auspice) JSON for visualization.

# Running

After [installing augur and auspice](https://nextstrain.org/docs/getting-started/installation) this script can be run via the supplied Snakefile via
```
snakemake clean
snakemake
```

Alternatively, each command can be run independently via:
```
ruby scripts/convert-beast-tree-to-newick.rb \
  data/MERS_CoV_274_mcc.tree \
  > results/tree_raw.nwk

augur refine \
  --tree results/tree_raw.nwk \
  --alignment data/MERS_CoV_274_CDS.fasta \
  --metadata data/MERS_CoV_274_metadata.tsv \
  --output-tree results/tree.nwk \
  --output-node-data results/branch_lengths.json

augur export \
  --tree results/tree.nwk \
  --metadata data/MERS_CoV_274_metadata.tsv \
  --node-data results/branch_lengths.json \
  --colors config/colors.tsv \
  --panels tree \
  --extra-traits host \
  --auspice-config config/auspice_config.json \
  --output-tree auspice/mers-beast-tutorial_tree.json \
  --output-meta auspice/mers-beast-tutorial_meta.json
```

# Augur version

Currently, use branch `export-safety-checks` in augur.
