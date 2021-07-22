import matlab.engine as engine
import sys
import os

if __name__ == '__main__':
    print(os.getcwd())
    os.chdir("radar_script")
    args = sys.argv
    eng = engine.start_matlab('-nodisplay')
    eng.processer2(args[1],args[2],nargout=0)

    root = "mat_data/"+args[1]
    kind = args[2]
    types = {'dry': '0',
             'wet': '1', }
    name_list = root.split('/')
    name = name_list[-1]
    if not os.path.exists(name):
        os.mkdir(name)
    type_list = os.listdir(os.path.join(root, kind))
    if not os.path.exists(os.path.join('../data/DATA',name)):
        os.mkdir(os.path.join("../data/DATA",name))
    file = os.path.join('../data/DATA',name,kind)
    all_file = file + '.txt'
    source_file = file + '_s.txt'
    target_file = file + '_t.txt'
    for file_path in [all_file, source_file, target_file]:
        if os.path.exists(file_path):
            os.remove(file_path)
    rate = 0.7
    for type in type_list:
        image_list = os.listdir(os.path.join(root, kind, type))
        split_n = round(rate * len(image_list))
        with open(all_file, 'a') as f:
            for image_path in image_list:
                path = './radar_script/mat_data/' + '/'.join([name, kind, type, image_path]) + ' ' + types[type]
                f.write(path + '\n')
        with open(source_file, 'a') as f:
            for image_path in image_list[0:split_n]:
                path = './radar_script/mat_data/' + '/'.join([name, kind, type, image_path]) + ' ' + types[type]
                f.write(path + '\n')
        with open(target_file, 'a') as f:
            for image_path in image_list[split_n:]:
                path = './radar_script/mat_data/' + '/'.join([name, kind, type, image_path]) + ' ' + types[type]
                f.write(path + '\n')