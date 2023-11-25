from random import randint
import sys
import traceback
import time

import cosim
import vfbdb


WRITE_FIFO_PATH = "/tmp/fbdl-example/python-vhdl"
READ_FIFO_PATH = "/tmp/fbdl-example/vhdl-python"

CLK_PERIOD = 50


def delay():
    return 3 * CLK_PERIOD


iface = cosim.Iface(WRITE_FIFO_PATH, READ_FIFO_PATH, delay, True)


def write_read_test(Main):
    print("\n\nPerforming Write Read Test")

    r = randint(0, 2 ** Main.C1.width - 1)
    Main.C1.write(r)
    assert Main.C1.read() == r
    assert Main.S1.read() == r

    r = randint(0, 2 ** Main.C2.width - 1)
    Main.C2.write(r)
    assert Main.C2.read() == r
    assert Main.S2.read() == r

    r = randint(0, 2 ** Main.C3.width - 1)
    Main.C3.write(r)
    assert Main.C3.read() == r
    assert Main.S3.read() == r

    print("Write Read Test Passed\n")


def array_test(Main):
    print("\n\nPerforming Array Test")

    data = []
    for _ in range(len(Main.CA)):
        data.append(randint(0, 2 ** Main.CA.width - 1))
    Main.CA.write(data)

    rdata = Main.CA.read()
    assert rdata == data, f"got {rdata}, want {data}"

    rdata = Main.SA.read()
    assert rdata == data, f"got {rdata}, want {data}"

    print("Array Test Passed\n")


def counter_test(Main):
    print("\n\nPerforming Counter Test")
    cnt = Main.Counter.read()
    print(f"counter = {cnt}")


def add_test(Main):
    print("\n\nPerforming Add Test")

    a = randint(0, 2 ** 20 - 1)
    b = randint(0, 2 ** 10 - 1)
    c = randint(0, 2 ** 8 - 1)

    sum = Main.Subblock.Add(a, b, c)[0]
    assert sum == a + b + c

    print("Add Test Passed\n")


def mask_test(Main):
    print("\n\nPerforming Mask Test")

    bits = [1, 3, 8, 15]
    Main.Mask.set(bits)
    mask = Main.Mask.read()
    print(mask)
    for idx in range(Main.Mask.width):
        val = mask & (1 << idx)
        if idx in bits:
            assert val == 1 << idx, f"bit {idx} not set"
        else:
            assert val == 0, f"bit {idx} set"

    Main.Mask.toggle(1)
    assert Main.Mask.read() & (1 << 1) == 0, "mask toggle didn't work"

    print("Mask Test Passed\n")

try:
    print("\n\nStarting Cosimulation\n")

    Main = vfbdb.Main(iface)

    id = Main.ID.read()
    assert id == Main.ID.value, f"Read wrong ID {id}, expecting {Tb.ID.value}"

    write_read_test(Main)
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
