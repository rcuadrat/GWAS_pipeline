#!/usr/bin/env python
import pandas as pd
import sys

# inputs: phenotype table and pattern

df=pd.read_table(sys.argv[1])

# col=list(df.columns)

# if len(sys.argv) > 2:
#     pattern = sys.argv[2]
# else:
#     pattern="Ta"


# col2=[x for x in col if pattern  in x]

col2=list(df.columns[df.loc[0]=="P"]) 


pd.DataFrame(col2).to_csv("../list_of_variables.tsv",sep="\t",index=False,header=False)

