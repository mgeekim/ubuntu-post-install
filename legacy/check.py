import os
os.environ["CUDA_VISIBLE_DEVICES"] = "6"

import tensorflow as tf
print(tf.test.is_gpu_available())