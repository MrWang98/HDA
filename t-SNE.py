from sklearn.manifold import TSNE
from sklearn.datasets import load_iris,load_digits
from sklearn.decomposition import PCA
import matplotlib.pyplot as plt
import numpy as np
from sklearn.utils import Bunch
from PIL import Image
import os
from pylab import array
# config InlineBackend.figure_format = "svg"

name = '30d'
root = os.path.join('radar_script','mat_data','wzy',name)
kinds={'dry':0,
       'wet':1}
flat_data=[]
target=[]
images=[]
for kind in os.listdir(root):
    image_paths = os.listdir(os.path.join(root,kind))
    for image_name in image_paths:
        image_path=os.path.join(root,kind,image_name)
        image = Image.open(image_path)
        raw_data = array(image)

        images.append(raw_data)
        flat_data.append(raw_data.flatten())
        target.append(kinds[kind])

flat_data = np.array(flat_data)
target = np.array(target)
frame=None
feature_names = []
x,y = images[0].shape
for m in range(x):
    for n in range(y):
        feature_names.append('pixel_{}_{}'.format(m,n))
target_names=np.arange(2)
images = np.array(images)
descr = 'test'

# digits = load_digits()
digits = Bunch(data=flat_data, #ndarry(1797,65)
                 target=target, #ndarry(1797,)
                 frame=frame, #None
                 feature_names=feature_names, #list64 ['pixel_0_0','pixel_0_1'...'pixel_8_8']
                 target_names=np.arange(10),
                 images=images, #ndarry(1797,8,8)
                 DESCR=descr) #str: discription

X_tsne = TSNE(n_components=2, random_state=33).fit_transform(digits.data)
X_pca = PCA(n_components=2).fit_transform(digits.data)

font = {"color": "darkred",
        "size": 13,
        "family" : "serif"}

plt.style.use("dark_background")
plt.figure(figsize=(8.5, 4))
plt.subplot(1, 2, 1)
plt.scatter(X_tsne[:, 0], X_tsne[:, 1], c=digits.target, alpha=0.6,
            cmap=plt.cm.get_cmap('rainbow', 10))
plt.title("t-SNE({})".format(name), fontdict=font)
cbar = plt.colorbar(ticks=range(10))
cbar.set_label(label='digit value', fontdict=font)
plt.clim(-0.5, 9.5)
plt.subplot(1, 2, 2)
plt.scatter(X_pca[:, 0], X_pca[:, 1], c=digits.target, alpha=0.6,
            cmap=plt.cm.get_cmap('rainbow', 10))
plt.title("PCA({})".format(name), fontdict=font)
cbar = plt.colorbar(ticks=range(10))
cbar.set_label(label='digit value', fontdict=font)
plt.clim(-0.5, 9.5)
plt.tight_layout()
plt.show()