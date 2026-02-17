#!/bin/bash
set -e
WORKSPACE_DIR=$(pwd)

## Installing Habitat-lab from source according to https://github.com/jacobkrantz/VLN-CE?tab=readme-ov-file#setup ##
echo 'Part 1'
echo 'Testing that Habitat-sim (0.1.7v) works properly and linked to our navila anaconda environment'
source /opt/conda/etc/profile.d/conda.sh
conda activate navila-eval
python -c "import habitat_sim; print('Habitat-Sim found at:', habitat_sim.__file__)"
python -c "import habitat_sim; print('✅ Loaded Habitat-Sim version:', habitat_sim.__version__)"

## Assuming habitat-sim is already installed and the previous test works correctly
echo 'Part 2'
echo 'Cloning Habitat-lab'
git clone --branch v0.1.7 https://github.com/facebookresearch/habitat-lab.git
cd habitat-lab
# installs both habitat and habitat_baselines
pip install pyyaml
pip install scikit-build
pip install scikit-build cmake ninja
pip install cffi==1.15.1 lmdb==1.3.0
pip install msgpack==1.0.2

# Replace line 4 in requirements.txt so it will install the latest tensorflow instead of the old version 1.13:
sed -i '4s/.*/tensorflow/' "$WORKSPACE_DIR/habitat-lab/habitat_baselines/rl/requirements.txt"

python -m pip install -r requirements.txt
python -m pip install -r habitat_baselines/rl/requirements.txt
python -m pip install -r habitat_baselines/rl/ddppo/requirements.txt
python setup.py develop --all
#conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia

###############################################################
# FIX TORCH — REQUIRED — insert this block
###############################################################
echo '[Fix] Reinstalling correct PyTorch build (CUDA 12.1)'
pip uninstall -y torch torchvision torchaudio || true
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
###############################################################


echo 'Part 3'
echo 'Verify installation'
python -c "import habitat; print('Habitat-Lab version:', habitat.__version__)"
python -c "import habitat_sim; import habitat; print('Habitat-Sim and Habitat-Lab fully operational ✅')"
