#!/bin/bash
set -e
WORKSPACE_DIR=$(pwd)

echo 'Part 1'
echo 'Cloning and installing NaVILA:'
cd "$WORKSPACE_DIR"
git clone https://github.com/AnjieCheng/NaVILA.git
cd NaVILA

echo 'Part 2'
echo 'Replacing NaVILAs original installed files with modified fixed files:'
cp "$WORKSPACE_DIR/Modified_files/Modified/vlnce_task.yaml" "$WORKSPACE_DIR/NaVILA/evaluation/habitat_extensions/config"
cp "$WORKSPACE_DIR/Modified_files/Modified/sft_8frames.sh" "$WORKSPACE_DIR/NaVILA/scripts/train"
cp "$WORKSPACE_DIR/Modified_files/Modified/README.md" "$WORKSPACE_DIR/NaVILA"

cp "$WORKSPACE_DIR/Modified_files/Modified/navila.yaml" "$WORKSPACE_DIR/NaVILA/evaluation/vlnce_baselines/config/r2r_baselines/"
cp "$WORKSPACE_DIR/Modified_files/Modified/r2r.sh" "$WORKSPACE_DIR/NaVILA/evaluation/scripts/eval"
cp "$WORKSPACE_DIR/Modified_files/Modified/sft_8frames_new.sh" "$WORKSPACE_DIR/NaVILA/scripts/train"
cp "$WORKSPACE_DIR/Modified_files/Modified/datasets_mixture.py" "$WORKSPACE_DIR/NaVILA/llava/data"
cp "$WORKSPACE_DIR/Modified_files/Modified/debug_train_mem.py" "$WORKSPACE_DIR/NaVILA"
cp "$WORKSPACE_DIR/Modified_files/Modified/common.py" "$WORKSPACE_DIR/habitat-sim/build/lib.linux-x86_64-cpython-310/habitat_sim/utils"

echo 'Part 3'
echo 'Applying the following hotfix, to resolve NumPy compatibility issues:'
sed -i "11c\# path for pkg in site_pkgs for path in glob.glob(os.path.join(pkg, 'habitat_sim-0.1.7*.egg', 'habitat_sim', 'utils', 'common.py'))\n    path for pkg in site_pkgs for path in glob.glob(os.path.join(pkg, 'habitat_sim', 'utils', 'common.py'))" \
"$WORKSPACE_DIR/NaVILA/evaluation/scripts/habitat_sim_autofix.py"

python evaluation/scripts/habitat_sim_autofix.py # replace habitat_sim/utils/common.py


echo 'Part 4'
echo 'Install VLN-CE Dependencies:'
pip install -r evaluation/requirements.txt

echo 'Part 5'
echo 'Installing VILA Dependencies:'
# Install FlashAttention2
pip install https://github.com/Dao-AILab/flash-attention/releases/download/v2.5.8/flash_attn-2.5.8+cu122torch2.3cxx11abiFALSE-cp310-cp310-linux_x86_64.whl
# 1️⃣ Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"
rustc --version  # confirm installed

# 2️⃣ Upgrade pip, setuptools, wheel
pip install --upgrade pip setuptools wheel

# 3️⃣ Now install tokenizers
pip install tokenizers==0.15.2


# Install VILA (assum in root dir)

cd "$WORKSPACE_DIR/NaVILA"

# Regular install (not editable)
pip install .
pip install ".[train]"
pip install ".[eval]"

# Install older Transformers compatible with Python 3.6
pip install transformers==4.37.2

site_pkg_path=$(python -c 'import site; print(site.getsitepackages()[0])')

# Copy replacements only if directories exist
if [ -d "./llava/train/transformers_replace" ]; then
    cp -rv ./llava/train/transformers_replace/* "$site_pkg_path/transformers/" || echo "⚠️ transformers_replace missing"
fi

if [ -d "./llava/train/deepspeed_replace" ]; then
    cp -rv ./llava/train/deepspeed_replace/* "$site_pkg_path/deepspeed/" || echo "⚠️ deepspeed_replace missing"
fi

echo "=== Part 6: Fixing WebDataset Version for VLN-CE Compatibility ==="
pip install webdataset==0.1.103


echo 'Part 7'
echo 'Linking the local llava installation registry folder into the installed package path:'
# Remove any stale or broken registry path in the installed llava
rm -rf /opt/conda/envs/navila-eval/lib/python3.10/site-packages/llava/data/registry
# Remove any broken eval folder inside site-packages
rm -rf /opt/conda/envs/navila-eval/lib/python3.10/site-packages/llava/eval


# Link your repo’s real registry folder into the installed package path
ln -s "$WORKSPACE_DIR/NaVILA/llava/data/registry" \
      /opt/conda/envs/navila-eval/lib/python3.10/site-packages/llava/data/registry
      
# Create a symlink from your repo's eval folder to site-packages
ln -s "$WORKSPACE_DIR/NaVILA/llava/eval" \
      /opt/conda/envs/navila-eval/lib/python3.10/site-packages/llava/eval


echo "✅ Installation complete!"
