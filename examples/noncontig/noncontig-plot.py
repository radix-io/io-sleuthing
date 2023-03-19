#!/usr/bin/env python

import matplotlib.pyplot as plt
import pandas as pd


df = pd.read_csv("ior-noncontig-write.dat", delim_whitespace=True, nrows=2)
# labels for the cases
df.insert(0, "approach", ["data sieving", "naive"])

ylow_err = df["Min(MiB)"]
ylow_err = (ylow_err - df["Mean(MiB)"]).abs()

yhigh_err = df["Max(MiB)"]
yhigh_err = (yhigh_err - df["Mean(MiB)"]).abs()

yerr = [ylow_err, yhigh_err]

plt.bar("approach", "Mean(MiB)", data=df, yerr=yerr)
plt.ylabel("Bandwidth (MiB/sec)")
plt.title("Comparing noncontiguous I/O optimizations")

plt.savefig("ior-noncontig-indep.png")

df = pd.read_csv("ior-noncontig-write.dat", delim_whitespace=True, nrows=3)
# labels for the cases
df.insert(0, "approach", ["data sieving", "naive", "collective"])

ylow_err = df["Min(MiB)"]
ylow_err = (ylow_err - df["Mean(MiB)"]).abs()

yhigh_err = df["Max(MiB)"]
yhigh_err = (yhigh_err - df["Mean(MiB)"]).abs()

yerr = [ylow_err, yhigh_err]

plt.bar("approach", "Mean(MiB)", data=df, yerr=yerr)
plt.ylabel("Bandwidth (MiB/sec)")
plt.title("Comparing noncontiguous I/O optimizations")

plt.savefig("ior-noncontig-indep-and-collective.png")
