#!/usr/bin/env python

import matplotlib.pyplot as plt
import pandas as pd


def process_input(data):
    df = pd.read_csv(data, delim_whitespace=True, nrows=8)
    # ior output doesn't contain stripe count... a bit fragile, sorry!
    df.insert(0, "stripe", [1, 2, 5, 10, 20, 40, 80, 160])
    # ior output is in MiB, but GiB might be more legible here
    df["Mean(MiB)"] = df["Mean(MiB)"].div(1024)
    df["Max(MiB)"] = df["Max(MiB)"].div(1024)
    df["Min(MiB)"] = df["Min(MiB)"].div(1024)

    # IOR gives us Min, Max, and Mean, but matplotlib wants deltas
    # lables are as IOR gave us, even though we've converted to GiB
    ylow_err = df["Min(MiB)"]
    ylow_err = (ylow_err - df["Mean(MiB)"]).abs()

    yhigh_err = df["Max(MiB)"]
    yhigh_err = (yhigh_err - df["Mean(MiB)"]).abs()

    yerr = [ylow_err, yhigh_err]

    return(df, yerr)


(stripe_writes, yerr) = process_input("ior-write128.dat")
plt.errorbar("stripe", "Mean(MiB)", data=stripe_writes, yerr=yerr,
             label="128 nodes")

(stripe_reads, yerr) = process_input("ior-read128.dat")
plt.errorbar("stripe", "Mean(MiB)", data=stripe_reads, yerr=yerr,
             label="Read")

plt.legend()
plt.xlabel("stripe count")
plt.ylabel("Bandwidth (GiB)")
plt.title("IOR performance vs stripe count")

plt.savefig("ior-stripe-count-128.png")
