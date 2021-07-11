import matlab.engine
import os

def image_processer(data_path,range,flag=False) :
    os.chdir("./radar_script")
    data_path = list(data_path)
    if not data_path[-1]=='/':
        data_path=''.join(data_path)
        data_path = data_path + '/'
    else:
        data_path=''.join(data_path)
    image_path = 'mat_data/'+data_path.split('/')[-2]+'/'
    if(flag):
        eng = matlab.engine.start_matlab("-nodisplay")
        y,image_path = eng.handleFunction1(data_path,range,nargout=2)
        print("{}, all images created".format(y))
    return image_path

def write_txt(image_path,rate):
    image_path = list(image_path)
    if image_path[-1]=='/':
        image_path[-1] = ''
    image_path = ''.join(image_path)
    labels = {'dry': 0,
              'wet': 1, }
    image_root = os.path.join(image_path)

    txt_root = '../data/DATA'
    dir = image_path.split('/')[-1]

    all_path = os.path.join(txt_root,dir + ".txt")
    sorce_path = os.path.join(txt_root,dir + "_s.txt")
    target_path = os.path.join(txt_root,dir + "_t.txt")
    for path in [all_path,sorce_path,target_path]:
        if os.path.exists(path):
            os.remove(path)


    type_list = os.listdir(image_root)  # dry. wet
    for type in type_list:
        image_list = os.listdir(os.path.join(image_root, type))  # 3_1.png, 3_2.png, ......
        s_scal = round(rate * len(image_list))
        with open(all_path, 'a') as f:
            for image in image_list:
                image_path = '/'.join([".", "radar_script", image_root, type, image])
                f.write("{} {}\n".format(image_path, labels[type]))
        with open(sorce_path, 'a') as f:
            for image in image_list[:s_scal]:
                image_path = '/'.join([".", "radar_script", image_root, type, image])
                f.write("{} {}\n".format(image_path, labels[type]))
        with open(target_path, 'a') as f:
            for image in image_list[s_scal:]:
                image_path = '/'.join([".", "radar_script",image_root, type, image])
                f.write("{} {}\n".format(image_path, labels[type]))
    cur_path = os.path.abspath(os.curdir)
    if cur_path.split('/')[-1] == 'radar_script':
        os.chdir("..")
    txt_root = './data/DATA'
    all_path = os.path.join(txt_root, dir + ".txt")
    sorce_path = os.path.join(txt_root, dir + "_s.txt")
    target_path = os.path.join(txt_root, dir + "_t.txt")
    return all_path,sorce_path,target_path

if __name__ == "__main__":
    # eng = matlab.engine.start_matlab("-nodispaly")
    # data_path = "D:\lab\radar_script\raw_data\210324\20cm_withBreath2\";
    # data_path = "D:\lab\radar_script\raw_data\210324\20cm_onlyBreath\";
    # data_path = "D:\lab\radar_script\raw_data\210325\20cm_withMetal\";
    # data_path = "D:\lab\radar_script\raw_data\210324\20cm_woodWithBreath\";
    # data_path = "D:\lab\radar_script\raw_data\210402\20cm_withCloth_1_4\";
    # data_path = "D:\lab\radar_script\raw_data\210402\20cm_1_4\";
    # data_path = "D:\lab\radar_script\raw_data\210403\20cm_1_2\";
    # data_path = "D:\lab\radar_script\raw_data\210402\20cm_withQuilt\";
    # data_path = "D:\lab\radar_script\raw_data\210609\adult\";
    # data_path = "D:\lab\radar_script\raw_data\210611\phone_nobreath\";
    # data_path = "D:\lab\radar_script\raw_data\210611\phone_breath\";
    # data_path = "D:\lab\radar_script\raw_data\210611\adult_bg\";
    data_path = r"../raw_data/210621/150cm"
    range = 256
    image_path = image_processer(data_path,range,flag=True)
    all_path,sorce_path,target_path = write_txt(image_path,0.7)
    # eng = matlab.engine.start_matlab("-nodispaly")
    # y,z = eng.test(1,nargout=2)
    # print(y)
    # print(z)