#!/bin/bash
#SBATCH -J guxiang_45d
#SBATCH -o slurm.out
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --gres=gpu:1

conda activate pytorch
python processer.py fck