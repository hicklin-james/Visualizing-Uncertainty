import numpy as np

def strokeRiskData(data_file):
  mean = -25.2
  sd = 4
  sampleSize = 1000
  data = np.random.normal(mean, sd, sampleSize)
  warfarinDelta = 0.07

  data_file.write("strokeRisk: {\n")
  data_file.write("data: [")
  data_file.write(",".join(map(str, data)))
  data_file.write("],\ndelta: ")
  data_file.write(str(warfarinDelta))
  data_file.write("\n}")

def bleedRiskData(data_file):
  mean = 25.3
  sd = 20
  sampleSize = 3000
  data = np.random.normal(mean, sd, sampleSize)
  bleedDelta = 0.1

  data_file.write("bleedRisk: {\n")
  data_file.write("data: [")
  data_file.write(",".join(map(str, data)))
  data_file.write("],\ndelta: ")
  data_file.write(str(bleedDelta))
  data_file.write("\n}")

def ichRiskData(data_file):
  mean = 9.3
  sd = 2.8
  sampleSize = 140
  data = np.random.normal(mean, sd, sampleSize)
  ichDelta = 0.06

  data_file.write("ichRisk: {\n")
  data_file.write("data: [")
  data_file.write(",".join(map(str, data)))
  data_file.write("],\ndelta: ")
  data_file.write(str(ichDelta))
  data_file.write("\n}")
  #f.close()

def abdoRiskData(data_file):
  mean = 27
  sd = 30
  sampleSize = 200
  data = np.random.normal(mean, sd, sampleSize)
  abdoPainDelta = 0.06

  data_file.write("abdoPain: {\n")
  data_file.write("data: [")
  data_file.write(",".join(map(str, data)))
  data_file.write("],\ndelta: ")
  data_file.write(str(abdoPainDelta))
  data_file.write("\n}")

data_file = "synthetic_data.js"
f = open(data_file, "wb")
f.write("var syntheticData = {\n")

strokeRiskData(f)
f.write(",")
bleedRiskData(f)
f.write(",")
ichRiskData(f)
f.write(",")
abdoRiskData(f)

f.write("};")
f.close()