#!/bin/bash
#SBATCH -J test
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:1

python test.py