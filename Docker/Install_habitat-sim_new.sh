#!/bin/bash
# initialize conda in the current shell so that when you call conda activate navila-eval it wont invoke a "conda init error". 
source /opt/conda/etc/profile.d/conda.sh
WORKSPACE_DIR=$(pwd)

set -e

## Installing Habitat-sim from source according to https://github.com/facebookresearch/habitat-sim/blob/v0.1.7/BUILD_FROM_SOURCE.md ##
echo 'Part 1'
# We require python>=3.6 (3.13) and cmake>=3.10
echo 'Creating a Conda Environment with Python 3.10 & cmake=3.14'
conda create -n navila-eval python=3.10.* cmake=3.14 -c conda-forge
conda activate navila-eval

echo 'Part 2'
echo 'Cloning Habitat-sim github repository.'
# Checkout the latest stable release
git clone --branch stable https://github.com/facebookresearch/habitat-sim.git
cd "$WORKSPACE_DIR/habitat-sim"

git checkout v0.1.7
git submodule update --init --recursive

echo 'Part 3'
echo 'Installing Dependencies - Note: We require python>=3.6 and cmake>=3.10'
echo 'Common dependencies:'
pip install -r requirements.txt

echo 'Linux (Tested with Ubuntu 18.04 with gcc 7.4.0):'
# See this configuration for a full list of dependencies that our CI installs on a clean Ubuntu VM. If you run into build errors later, this is a good place to check if all dependencies are installed.
sudo apt-get update || true
# These are fairly ubiquitous packages and your system likely has them already,
# but if not, let's get the essentials for EGL support:
sudo apt-get install -y --no-install-recommends \
    libjpeg-dev libglm-dev \
    libgl1 libglx-mesa0 libgl1-mesa-dri \
    libegl1-mesa-dev libgles2-mesa-dev mesa-utils xorg-dev freeglut3-dev

echo 'Part 4'
cd "$WORKSPACE_DIR/habitat-sim"
# Choose between the options by commenting out the other.

# Option #1
echo 'Building Habitat-Sim 0.1.7v (For systems with CUDA (to build CUDA features))'
pip install pybind11==2.10.4
conda install -c conda-forge libstdcxx-ng=13
python setup.py install --with-cuda \
  --cmake-args="-DUSE_SYSTEM_PYBIND11=ON \
                -DBUILD_WITH_INTERNAL_PYBIND11=OFF \
                -Dpybind11_DIR=$(python -m pybind11 --cmakedir) \
		-DCUDA_USE_STATIC_CUDA_RUNTIME=OFF \
                -DCMAKE_BUILD_TYPE=RelWithDebInfo"

# Option #2
#echo 'Building Habitat-Sim 0.1.7v (With physics simulation via Bullet Physics SDK: First, install Bullet Physics using your systems package manager.)'
#sudo apt-get install libbullet-dev
#python setup.py install --bullet    # build habitat with bullet physics

echo 'Part 5'
echo 'Adding habitat-sim to your PYTHONPATH'
cd "$WORKSPACE_DIR"

# Ensure activate.d directory exists
#mkdir -p "$CONDA_ENV_PATH/etc/conda/activate.d"
mkdir -p "$CONDA_PREFIX/etc/conda/activate.d"

# Detect Python ABI (e.g. cpython-310)
PYTHON_TAG=$(python - <<EOF
import sys
print(f"cpython-{sys.version_info.major}{sys.version_info.minor}")
EOF
)

# Resolve Habitat-Sim build directory
BUILD_DIR="$WORKSPACE_DIR/habitat-sim/build/lib.linux-x86_64-${PYTHON_TAG}"

# Check if directory exists
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ Habitat-Sim build dir not found: $BUILD_DIR"
  exit 1
fi

# Write environment variables to env_vars.sh
cat > "$CONDA_PREFIX/etc/conda/activate.d/env_vars.sh" <<EOL
export PYTHONPATH=$BUILD_DIR:\$PYTHONPATH
export LD_LIBRARY_PATH=$BUILD_DIR:\$LD_LIBRARY_PATH
EOL

echo 'Part 6'
echo 'Testing the installation - (You shuold see "Habitat-Sim version: 0.1.7" in case of success)'
python -c "import habitat_sim; print('✅ Loaded Habitat-Sim version:', habitat_sim.__version__)"  

#cd &WORKSPACE_DIR/habitat-sim

#echo 'Testing by showing a visual GUI'
#python examples/example.py --dataset habitat-test-scenes --scene .data/test_assets/scenes/simple_room.glb
