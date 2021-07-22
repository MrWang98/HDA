import os
root = "./radar_script/mat_data/guxiang"
types = {'dry':'0',
         'wet':'1',}
name_list = root.split('/')
name = name_list[-1]
if not os.path.exists(os.path.join('result',name)):
        os.mkdir(os.path.join('result',name))
dir_list = os.listdir(root)
for dir in dir_list:
    type_list = os.listdir(os.path.join(root,dir))
    name_path = os.path.join('data/DATA',name)
    if not os.path.exists(name_path):
        os.mkdir(name_path)
    file = os.path.join(name_path,dir)
    all_file = file + '.txt'
    source_file = file + '_s.txt'
    target_file = file + '_t.txt'
    for file_path in [all_file,source_file,target_file]:
        if os.path.exists(file_path):
            os.remove(file_path)
    rate = 0.7
    for type in type_list:
        image_list = os.listdir(os.path.join(root,dir,type))
        split_n = round(rate * len(image_list))
        with open(all_file,'a') as f:
            for image_path in image_list:
                path = './radar_script/mat_data/'+ '/'.join([name,dir,type,image_path]) + ' ' + types[type]
                f.write(path+'\n')
        with open(source_file,'a') as f:
            for image_path in image_list[0:split_n]:
                path = './radar_script/mat_data/'+ '/'.join([name,dir,type,image_path]) + ' ' + types[type]
                f.write(path+'\n')
        with open(target_file,'a') as f:
            for image_path in image_list[split_n:]:
                path = './radar_script/mat_data/'+ '/'.join([name,dir,type,image_path]) + ' ' + types[type]
                f.write(path+'\n')