### author: twilts
### purpose: train tensorflow boosted tree model
import numpy as np
import pandas as pd
import tensorflow as tf
import os
import sys
from sklearn.model_selection import train_test_split
from sqlalchemy import create_engine
tf.enable_eager_execution()


def serving_input_receiver_fn():
    serialized_tf_sample = tf.placeholder(dtype=tf.string,shape=[None], name='input_example_tensor')
    receiver_tensors = {'example': serialized_tf_sample}
    example_proto = {
        'Latitude': tf.FixedLenFeature(dtype=tf.float32, shape=[1]),
        'Longitude': tf.FixedLenFeature(dtype=tf.float32, shape=[1]),
        'Speed': tf.FixedLenFeature(dtype=tf.float32, shape=[1]),
        'Volume': tf.FixedLenFeature(dtype=tf.float32, shape=[1]),
        'Celsius': tf.FixedLenFeature(dtype=tf.float32, shape=[1]),
        }
    features = tf.parse_example(serialized_tf_sample, example_proto)
    return tf.estimator.export.ServingInputReceiver(features, receiver_tensors)

def make_input_fn(X, y, n_epochs=None, shuffle=True):
    def input_fn():
        dataset = tf.data.Dataset.from_tensor_slices((dict(X), y))
        if shuffle:
          dataset = dataset.shuffle(NUM_EXAMPLES)
        # For training, cycle thru dataset as many times as need (n_epochs=None).    
        dataset = dataset.repeat(n_epochs)  
        # In memory training doesn't use batching.
        dataset = dataset.batch(NUM_EXAMPLES)
        return dataset
    return input_fn

### write stats file
def writeFile(best_acc):
    f = open('/data/stats', 'w')
    f.write(str(best_acc))
    f.close()

### write accuracy history
def writeHistory(acc):
    f = open('/data/stats_history', 'a+')
    f.write("\n"+str(acc))
    f.close()

select_sql = "SELECT A.IsFire,C.Latitude,C.Longitude,D.Speed,E.Volume,B.Celsius FROM H_Fires AS A JOIN S_Temperature AS B ON A.H_Fire_id=B.H_Fire_id JOIN S_Geo AS C ON A.H_Fire_id=C.H_Fire_id JOIN S_Wind AS D ON A.H_Fire_id=D.H_Fire_id JOIN S_Precipitation AS E ON E.H_Fire_id=D.H_Fire_id"
cnx = create_engine('mysql+pymysql://root:mariapw@'+sys.argv[1]+':3306/FireDB').connect()
df = pd.read_sql(select_sql, cnx)
cnx.close()

df.IsFire = df.IsFire.astype(np.int32)
df.Latitude = df.Latitude.astype(np.float32)
df.Longitude = df.Longitude.astype(np.float32)
df.Speed = df.Speed.astype(np.float32)
df.Volume = df.Volume.astype(np.float32)
df.Celsius = df.Celsius.astype(np.float32)

target = df.pop("IsFire")

X_train, X_test, y_train, y_test = train_test_split(df, target, test_size=0.33, random_state=42)

NUM_EXAMPLES = len(y_train)
fc = tf.feature_column
NUMERIC_COLUMNS = ['Latitude','Longitude','Speed','Volume','Celsius']

feature_columns = []
for feature_name in NUMERIC_COLUMNS:
    feature_columns.append(fc.numeric_column(feature_name,dtype=tf.float32))

# Training and evaluation input functions.
train_input_fn = make_input_fn(X_train, y_train)
eval_input_fn = make_input_fn(X_test, y_test, shuffle=False, n_epochs=1)

n_batches = 5
est = tf.estimator.BoostedTreesClassifier(feature_columns,n_batches_per_layer=n_batches)
est.train(train_input_fn, max_steps=10)

# Eval.
results = est.evaluate(eval_input_fn)

if(os.path.exists('/data/stats')):
    file = open('/data/stats')
    for line in file:
        fields = line.strip().split()
        if(float(fields[0])<results['accuracy']):
            os.remove("/data/stats")
            est.export_saved_model("/data/models/", serving_input_receiver_fn)
            writeFile(results['accuracy'])
            writeHistory(results['accuracy'])
        else:
            writeHistory(float(fields[0]))
else:
    writeFile(results['accuracy'])
    writeHistory(results['accuracy'])
    est.export_saved_model("/data/models/", serving_input_receiver_fn)

print("training done")