python main.py --task data --dset baby-care --gpu_id 0 --lr 0.003 --seed 2019 --test_interval 500 --num_iterations 20004 --snapshot_interval 20000 --s_dset_path data/DATA/adult_20cm_s.txt --t_dset_path data/DATA/adult_20cm_t.txt --batch_size 32 --net ResNet50 --heuristic 1 --heuristic_num 3 --heuristic_initial True --num_labels 2 --output_dir HDA/DATA
