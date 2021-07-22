#!/bin/bash
#SBATCH -J matlab
#SBATCH -o matlab.out
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2

python radar_script/processer2.py ${1} ${2} 2> error/${1}/${2}.txt