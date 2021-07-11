#!/bin/bash
#SBATCH -J test
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=40
#SBATCH --gres=gpu:1
#conda activate pytorch
bash scripts/test2.sh
