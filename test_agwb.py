from random import randint
import sys
import traceback
import time

import cosim
import agwb


WRITE_FIFO_PATH = "/tmp/fbdl-example/python-vhdl"
READ_FIFO_PATH = "/tmp/fbdl-example/vhdl-python"

CLK_PERIOD = 50


def delay():
    return 3 * CLK_PERIOD


iface = cosim.Iface(WRITE_FIFO_PATH, READ_FIFO_PATH, delay, True)


def single_data_test(Main):
    print("\n\nPerforming Single Data Test")

    r = randint(0, 2 ** 7 - 1)
    Main.C1.write(r)
    assert Main.C1.read() == r
    assert Main.S1.read() == r

    r = randint(0, 2 ** 9 - 1)
    Main.C2.write(r)
    assert Main.C2.read() == r
    assert Main.S2.read() == r

    r = randint(0, 2 ** 12 - 1)
    Main.C3.write(r)
    assert Main.C3.read() == r
    assert Main.S3.read() == r

    print("Single Data Test Passed\n")


def array_test(Main):
    print("\n\nPerforming Array Test")

    data = []
    for _ in range(10):
        data.append(randint(0, 2 ** 8 - 1))

    for i in range(len(Main.CA4)):
        Main.CA4[i].Item0.write(data[0 + i * 4])
        Main.CA4[i].Item1.write(data[1 + i * 4])
        Main.CA4[i].Item2.write(data[2 + i * 4])
        Main.CA4[i].Item3.write(data[3 + i * 4])
    Main.CA2.Item0.write(data[8])
    Main.CA2.Item1.write(data[9])

    rdata = []
    for i in range(len(Main.CA4)):
        rdata.append(Main.CA4[i].Item0.read())
        rdata.append(Main.CA4[i].Item1.read())
        rdata.append(Main.CA4[i].Item2.read())
        rdata.append(Main.CA4[i].Item3.read())
    rdata.append(Main.CA2.Item0.read())
    rdata.append(Main.CA2.Item1.read())
    assert rdata == data, f"got {rdata}, want {data}"

    rdata = []
    for i in range(len(Main.SA4)):
        rdata.append(Main.SA4[i].Item0.read())
        rdata.append(Main.SA4[i].Item1.read())
        rdata.append(Main.SA4[i].Item2.read())
        rdata.append(Main.SA4[i].Item3.read())
    rdata.append(Main.SA2.Item0.read())
    rdata.append(Main.SA2.Item1.read())
    assert rdata == data, f"got {rdata}, want {data}"

    print("Array Test Passed\n")


def counter_test(Main):
    print("\n\nPerforming Counter Test")
    cnt0 = Main.Counter0.read()
    cnt1 = Main.Counter1.read()
    cnt = (cnt1 << 32) | cnt0
    print(f"counter = {cnt}")


def add_test(Main):
    print("\n\nPerforming Add Test")

    a = randint(0, 2 ** 20 - 1)
    b = randint(0, 2 ** 10 - 1)
    c = randint(0, 2 ** 8 - 1)

    Main.Subblock.Add0.A.write(a)
    Main.Subblock.Add0.B.write(b)
    Main.Subblock.Add1.C.write(c)
    assert Main.Subblock.Sum.read() == a + b + c

    print("Add Test Passed\n")


def mask_test(Main):
    print("\n\nPerforming Mask Test")

    # Setting particular bits
    bits = [1, 3, 8, 15]
    mask = 0
    for b in bits:
        mask |= 1 << b
    Main.Mask.write(mask)
    for idx in range(16):
        val = mask & (1 << idx)
        if idx in bits:
            assert val == 1 << idx, f"bit {idx} not set"
        else:
            assert val == 0, f"bit {idx} set"

    # Toggling bits
    mask = Main.Mask.read()
    mask ^= (1 << 1)
    Main.Mask.write(mask)
    assert Main.Mask.read() & (1 << 1) == 0, "mask toggle didn't work"

    print("Mask Test Passed\n")

try:
    print("\n\nStarting Cosimulation\n")

    Main = agwb.Main(iface, 0)

    single_data_test(Main)
    array_test(Main)
    counter_test(Main)
    add_test(Main)
    mask_test(Main)

    print("\nEnding Cosimulation")
    iface.wait(20 * CLK_PERIOD)
    iface.end(0)

except Exception as E:
    iface.end(1)
    print(traceback.format_exc())
