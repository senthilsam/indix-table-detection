# @author       :Senthilkumar Soundararajan
# @filename     :train_RandomForest_v1.0.1.py
# Purpose       :Used to tran and generate RF model
import os
import sys
from sklearn.ensemble import RandomForestClassifier
import pickle

if __name__ == "__main__":
    trainFile = raw_input( "Enter Training Set File: " )
    modelfile = raw_input( "Enter Model file: " )
    inputdata = []
    output = []
    # has_table has_neted_table has_no_row_col  has_one_row has_one_col row_count   col_count   head_count  has_title   has_attribs has_links   has_dimensions  has_details has_book_detals has_product_detals  has_electronics answer_label
    if os.path.isfile(trainFile):
        with open(trainFile) as file:
            for line in file:
                if line[0] == "#":
                    continue
                values = line.split("\t")
                length = len(values)
                feature = values[:length-1]
                inputdata.append(feature)
                out = values[length-1]
                out = out.rstrip()
                output.append(out)
    
    print "\n building  model \n"
    # train model
    DT_clf = RandomForestClassifier(n_estimators=10)
    # DT_clf = RandomForestClassifier(n_estimators=10, max_depth=None, min_samples_split=1, random_state=0)
    DT_clf = DT_clf.fit(inputdata, output)
    
    # file = modelfile + ".dot"
    # tree.export_graphviz(DT_clf,out_file=file)
    
    #dump model
    f = open( modelfile, 'wb')
    pickle.dump(DT_clf, f)
    f.close()
    