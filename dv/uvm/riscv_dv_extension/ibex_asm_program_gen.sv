// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

//-----------------------------------------------------------------------------------------
// RISC-V assembly program generator for ibex
//-----------------------------------------------------------------------------------------

class ibex_asm_program_gen extends riscv_asm_program_gen;

  `uvm_object_utils(ibex_asm_program_gen)
  `uvm_object_new

  virtual function void gen_program_header();
    // Override the cfg value, below field is not supported by ibex
    cfg.mstatus_mprv = 0;
    cfg.mstatus_mxr  = 0;
    cfg.mstatus_sum  = 0;
    cfg.mstatus_tvm  = 0;
    // The ibex core load the program from 0x80
    // Some address is reserved for hardware interrupt handling, need to decide if we need to copy
    // the init program from crt0.S later.
    instr_stream.push_back(".macro init");
    instr_stream.push_back(".endm");
    instr_stream.push_back(".section .text.init");
    instr_stream.push_back(".globl _start");
    instr_stream.push_back("j _start");
    // Align the start section to 0x80
    instr_stream.push_back(".align 7");
    instr_stream.push_back("_start: j _reset_entry");
    // ibex reserves 0x84-0x8C for trap handling, redirect everything mtvec_handler
    // 0x84 illegal instruction
    instr_stream.push_back(".align 2");
    instr_stream.push_back("j mtvec_handler");
    // 0x88 ECALL instruction handler
    instr_stream.push_back(".align 2");
    instr_stream.push_back("j mtvec_handler");
    // 0x8C LSU error
    instr_stream.push_back(".align 2");
    instr_stream.push_back("j mtvec_handler");
    // Starting point of the reset entry
    instr_stream.push_back("_reset_entry:");
  endfunction

endclass
