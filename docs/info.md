<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

## 8-bit Lightweight PRESENT Cipher Module

## Overview
This repository contains a Verilog implementation of an 8-bit lightweight block cipher. The design is inspired by the **PRESENT** cipher, utilizing a **Substitution-Permutation Network (SPN)** architecture. It is designed for area-constrained hardware environments (like TinyTapeout or small FPGAs).

The module is "unified," meaning it uses the same hardware resources to perform both **Encryption** and **Decryption**, toggled by a control signal.

---

## Technical Specifications
| Parameter | Value |
| :--- | :--- |
| **Data Block Width** | 8 bits |
| **Key Width** | 6 bits (Internal 8-bit expansion) |
| **Algorithm Type** | Substitution-Permutation Network (SPN) |
| **Rounds** | 4 |
| **Cycles per Op** | 4 Clock Cycles |

---

## Signal Description

| Port | Direction | Width | Description |Mapping with Top module pins|
| :--- | :--- | :--- | :--- |:----------------------------------|
| `clk` | Input | 1 | System Clock |Internally connected|
| `rst` | Input | 1 | Synchronous Reset (Active High) |Internally connected|
| `data_in` | Input | 8 | Input Plaintext / Ciphertext |ui_in|
| `key` | Input | 6 | Secret Key |uio_in[5:0]|
| `start` | Input | 1 | Start pulse to begin calculation |uio_in[6]|
| `enc_dec` | Input | 1 | Mode: `1` = Encrypt, `0` = Decrypt |uio_in[7]|
| `data_out` | Output | 8 | Resulting Ciphertext / Plaintext |uo_out|

---

## Architecture Details

### 1. Substitution Layer (S-Box)
The module implements a 4-bit non-linear S-Box. During encryption, the 8-bit state is split into two nibbles, and each is passed through the `sbox` function. During decryption, the `inv_sbox` function is used.

### 2. Permutation Layer
To provide bit-level diffusion, the bits are reordered in every round. 
* **Permute:** Shuffles bits to ensure influence spreads across the byte.
* **Inv_Permute:** The exact mirror mapping to restore bit order during decryption.

### 3. Key Schedule
The 6-bit input key is expanded to 8 bits by concatenating the first two bits to the end. A circular left shift (`rotl8`) is applied based on the current round number to generate a unique `round_key` for every stage of the SPN.

---

## Hardware Operation

### Encryption Flow
1. **Load:** When `start` is high, `state` captures `data_in`.
2. **AddRoundKey:** State is XORed with the generated `round_key`.
3. **SubBytes:** Both nibbles pass through the S-Box.
4. **Permute:** Bits are shuffled via the permutation layer.
5. **Repeat:** Process repeats for 4 rounds.

### Decryption Flow
1. **Load:** When `start` is high, `state` captures `data_in`.
2. **Inv_Permute:** Bits are unshuffled.
3. **Inv_SubBytes:** Both nibbles pass through the Inverse S-Box.
4. **AddRoundKey:** State is XORed with the `round_key`.
5. **Repeat:** Process counts down from round 3 to 0.

---

## Simulation
You can verify this module using **cocotb** or standard Verilog testbenches. 

**Example Test Vector:**
* **Input:** `0xDF`
* **Key:** `0b010010` (Hex `0x12`)
* **Mode:** Encrypt (`enc_dec = 1`)
* **Expected Result:** Check your simulation output after 4 clock cycles.

---


## How to test
To test in hardware, apply data, key, start, and enc_dec operation input via switches and observe output on LEDs.

## External hardware

No external hardware required
