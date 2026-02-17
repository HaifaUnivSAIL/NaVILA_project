#!/bin/bash
set -e

# Define the current project's conda environment name (i.e. navila12):
current_env="navila12"

echo 'Part 1'
echo 'Removing folders & the anaconda navila environment' 
#conda init
#source ~/.bashrc

#conda activate $current_env
#conda deactivate 
conda remove -n $current_env --all -y 
cd ~/WorkProjects/Navila_project
pip uninstall -y habitat-sim habitat-lab
rm -rf build/ dist/ *.egg-info
rm -rf NaVILA habitat-sim habitat-lab

echo 'Part 2'
echo 'Creating the anaconda navila environment'
conda create -n $current_env python=3.10 -y
conda activate $current_env


