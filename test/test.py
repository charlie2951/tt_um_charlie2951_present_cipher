# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge

# Helper to pack bits for uio_in
def pack_uio(key, start, enc_dec):
    return (enc_dec << 7) | (start << 6) | (key & 0x3F)

@cocotb.test()
async def crypto_test_with_assertions(dut):
    # Start Clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    dut.ena.value = 1
    await Timer(100, units="ns")
    dut.rst_n.value = 1
    await RisingEdge(dut.clk)

    # Define Test Cases (Input, Key, Start, Enc_Dec, Expected Output)
    # Note: Replace '0x??' with your actual expected hardware output
    test_cases = [
        {"ui": 0xDF, "key": 0b010010, "start": 1, "ed": 1, "expected": 0x61}, # Enc 1
        {"ui": 0x6A, "key": 0b11001,  "start": 1, "ed": 1, "expected": 0x8F}, # Enc 2
        {"ui": 0x61, "key": 0b010010, "start": 1, "ed": 0, "expected": 0xDF}, # Dec 1
    ]

    for test in test_cases:
        # Drive signals
        dut.ui_in.value = test["ui"]
        dut.uio_in.value = pack_uio(test["key"], test["start"], test["ed"])
        
        # Wait for logic to process (match Verilog #200)
        await Timer(200, units="ns")
        
        # Capture the actual output
        actual_out = int(dut.uo_out.value)
        
        # Automated Assertion
        assert actual_out == test["expected"], \
            f"FAIL: Input {hex(test['ui'])} with key {bin(test['key'])} " \
            f"Expected {hex(test['expected'])}, Got {hex(actual_out)}"
        
        dut._log.info(f"PASS: Input {hex(test['ui'])} -> Output {hex(actual_out)}")

        # Reset start signal for next iteration
        dut.uio_in.value = pack_uio(test["key"], 0, test["ed"])
        await Timer(10, units="ns")

    dut._log.info("All crypto tests passed successfully!")
