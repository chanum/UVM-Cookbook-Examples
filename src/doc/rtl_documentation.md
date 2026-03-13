# RTL Blocks Documentation

This document provides functional descriptions of all RTL blocks in this repository.

## Overview

The repository contains RTL designs for a **Peripheral Subsystem (PSS)** that includes:
- SPI Master Controller
- GPIO (General-Purpose I/O)
- UART (16550-compatible)
- Interrupt Controller + Programmable Interval Timer (ICPIT)
- AHB to APB Bridge

These blocks are integrated in the `pss.sv` top-level module.

---

## 1. SPI Master Controller (`spi_top.v`)

### Description
SPI (Serial Peripheral Interface) master controller with APB interface. Supports configurable character length (up to 128 bits), multiple slave select lines, and interrupt-driven operation.

### Features
- APB interface for register access
- Configurable clock divider (16-bit)
- Up to 8 slave select outputs
- MSB/LSB first transfer
- Programmable character length (1-128 bits)
- Interrupt on transfer complete
- Support for TX/RX on both clock edges

### Register Map (APB Address Offset)

| Offset | Register | Description |
|--------|----------|-------------|
| 0x00 | RX_0 | Receive data register 0 (bits 0-31) |
| 0x04 | RX_1 | Receive data register 1 (bits 32-63) |
| 0x08 | RX_2 | Receive data register 2 (bits 64-95) |
| 0x0C | RX_3 | Receive data register 3 (bits 96-127) |
| 0x10 | TX_0 | Transmit data register 0 |
| 0x14 | TX_1 | Transmit data register 1 |
| 0x18 | TX_2 | Transmit data register 2 |
| 0x1C | TX_3 | Transmit data register 3 |
| 0x20 | CTRL | Control register |
| 0x24 | DIVIDER | Clock divider register |
| 0x28 | SS | Slave select register |

### Control Register Bits (CTRL)

| Bit | Name | Description |
|-----|------|-------------|
| 13 | ASS | Automatic slave select |
| 12 | IE | Interrupt enable |
| 11 | LSB | LSB first (1) / MSB first (0) |
| 10 | TX_NEGEDGE | TX on negative edge |
| 9 | RX_NEGEDGE | RX on negative edge |
| 8 | GO | Start transfer (write 1 to start) |
| 6:0 | CHAR_LEN | Character length (1-128) |

### Interface Signals

```
spi_top (
  PCLK, PRESETN, PADDR[4:0], PWDATA[31:0], PRDATA[31:0],
  PWRITE, PSEL, PENABLE, PREADY, PSLVERR, IRQ,
  ss_pad_o[7:0], sclk_pad_o, mosi_pad_o, miso_pad_i
)
```

---

## 2. GPIO Controller (`gpio_top.v`)

### Description
General-Purpose I/O controller with APB interface. Supports up to 32 GPIO pins with configurable direction, interrupts, and external clock sampling.

### Features
- APB interface for register access
- Up to 32 GPIO pins
- Configurable input/output direction
- Interrupt generation on input change
- External clock for input sampling
- Auxiliary input support

### Register Map (APB Address Offset)

| Offset | Register | Description |
|--------|----------|-------------|
| 0x00 | RGPIO_IN | Input data (read-only) |
| 0x04 | RGPIO_OUT | Output data (write) |
| 0x08 | RGPIO_OE | Output enable (1=output) |
| 0x0C | RGPIO_INTE | Interrupt enable |
| 0x10 | RGPIO_PTRIG | Positive edge trigger |
| 0x14 | RGPIO_AUX | Auxiliary select |
| 0x18 | RGPIO_CTRL | Control register |
| 0x1C | RGPIO_INTS | Interrupt status |
| 0x20 | RGPIO_ECLK | External clock enable |
| 0x24 | RGPIO_NEC | Negative edge capture |

### Control Register Bits (RGPIO_CTRL)

| Bit | Name | Description |
|-----|------|-------------|
| 1 | INTS | Global interrupt status |
| 0 | EN | GPIO enable |

### Interface Signals

```
gpio_top (
  PCLK, PRESETN, PSEL, PADDR[7:0], PWDATA[31:0], PRDATA[31:0],
  PENABLE, PREADY, PSLVERR, PWRITE, IRQ,
  ext_pad_i[31:0], ext_pad_o[31:0], ext_padoe_o[31:0]
)
```

---

## 3. UART Controller (`uart_top.v`)

### Description
16550-compatible UART with APB interface. Supports full modem control, configurable baud rate, and FIFO operation.

### Features
- APB interface for register access
- 16550-compatible register set
- 16-byte receive/transmit FIFOs
- Configurable baud rate generator
- Full modem control signals (RTS, CTS, DTR, DSR, RI, DCD)
- Interrupt-driven operation

### Register Map (APB Address Offset)

| Offset | Register | Description |
|--------|----------|-------------|
| 0x00 | RHR/THR | Receive/Transmit Holding Register |
| 0x04 | IER | Interrupt Enable Register |
| 0x08 | FCR/IIR | FIFO Control / Interrupt ID |
| 0x0C | LCR | Line Control Register |
| 0x10 | MCR | Modem Control Register |
| 0x14 | LSR | Line Status Register |
| 0x18 | MSR | Modem Status Register |
| 0x1C | SCR | Scratch Register |
| 0x20 | DLL | Divisor Latch LSB |
| 0x24 | DLH | Divisor Latch MSB |

### Key Signals

```
uart_top (
  PCLK, PRESETn, PADDR[31:0], PWDATA[31:0], PRDATA[31:0],
  PWRITE, PENABLE, PSEL, PREADY, int_o,
  stx_pad_o, srx_pad_i,
  rts_pad_o, cts_pad_i, dtr_pad_o, dsr_pad_i, ri_pad_i, dcd_pad_i,
  baud_o
)
```

---

## 4. Interrupt Controller + PIT (`icpit.v`)

### Description
Combined Interrupt Controller and Programmable Interval Timer (PIT) with APB interface. Provides 8 interrupt request inputs, interrupt masking, and a 32-bit programmable timer.

### Features
- 8 interrupt request inputs
- Interrupt masking per source
- 32-bit programmable interval timer (PIT)
- Watchdog timer
- Combined interrupt output to processor

### Register Map (APB Address Offset)

| Offset | Register | Description |
|--------|----------|-------------|
| 0x00 | INTE | Interrupt Enable (bit 9 = watchdog enable) |
| 0x04 | INTS | Interrupt Status (write 1 to clear) |
| 0x08 | PIT_VAL | PIT Load Value |
| 0x0C | PIT_CNT | PIT Current Count |
| 0x10 | CTRL | Control (bit 1 = watchdog load, bit 0 = PIT load) |

### Interrupt Sources

| Bit | Source |
|-----|--------|
| 9 | Watchdog terminal count |
| 8 | PIT terminal count |
| 7:0 | External interrupt requests (IREQ[7:0]) |

### Interface Signals

```
icpit (
  PCLK, PRESETN, PADDR[2:0], PSEL, PENABLE, PWRITE,
  PWDATA[31:0], PRDATA[31:0], PREADY,
  IRQ, IREQ[7:0], PIT_OUT, WATCHDOG
)
```

---

## 5. AHB to APB Bridge (`ahb_apb_bridge.sv`)

### Description
Bridge converting AHB (Advanced High-performance Bus) transactions to APB (Advanced Peripheral Bus). Supports up to 8 APB slaves with configurable address ranges.

### Features
- AHB Lite interface (no split/retry)
- Configurable number of slaves (1-8)
- Programmable address ranges per slave
- Error response for invalid addresses
- PREADY/PSLVERR support from APB slaves

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| NO_OF_SLAVES | 8 | Number of APB slaves |
| SLAVE_START_ADDR_0 | 0x000 | Slave 0 start address |
| SLAVE_END_ADDR_0 | 0x0FF | Slave 0 end address |
| SLAVE_START_ADDR_1 | 0x100 | Slave 1 start address |
| ... | ... | ... |

### State Machine

The bridge implements a 3-state FSM:
1. **IDLE**: Waiting for AHB transaction
2. **SETUP**: Address phase, decode slave
3. **ACCESS**: Data phase, wait for PREADY

### Interface Signals

```
ahb_apb_bridge #(...) (
  // AHB Master side
  HCLK, HRESETn, HADDR[31:0], HTRANS[1:0], HWRITE,
  HSIZE[2:0], HBURST[2:0], HPROT[3:0], HWDATA[31:0], HSEL,
  HRDATA[31:0], HREADY, HRESP[1:0],
  // APB Slave side
  PADDR[31:0], PWDATA[31:0], PENABLE, PWRITE,
  PSEL[NO_OF_SLAVES-1:0], PRDATA[NO_OF_SLAVES-1:0],
  PREADY[NO_OF_SLAVES-1:0], PSLVERR[NO_OF_SLAVES-1:0]
)
```

---

## 6. Peripheral Subsystem (`pss.sv`)

### Description
Top-level integration of all peripherals with AHB host interface.

### Submodules
1. **AHB2APB Bridge** - Configured for 4 slaves
2. **SPI Master** - Address range 0x000-0x0FF
3. **GPIO** - Address range 0x100-0x1FF
4. **ICPIT** - Address range 0x200-0x2FF
5. **UART** - Address range 0x300-0x3FF

### Memory Map

| Address Range | Peripheral |
|--------------|------------|
| 0x000 - 0x0FF | SPI |
| 0x100 - 0x1FF | GPIO |
| 0x200 - 0x2FF | ICPIT |
| 0x300 - 0x3FF | UART |

### Interface Signals

```
pss (
  // AHB Host
  HCLK, HRESETn, HADDR[31:0], HTRANS[1:0], HWRITE,
  HSIZE[2:0], HBURST[2:0], HPROT[3:0], HWDATA[31:0], HSEL,
  HRDATA[31:0], HREADY, HRESP[1:0],
  // SPI
  spi_cs[7:0], spi_clk, spi_mosi, spi_miso,
  // GPIO
  gpi[31:0], gpo[31:0], gpoe[31:0],
  // UART
  rxd, txd, rts, cts, dtr, dsr, ri, dcd, baud,
  // External interrupts
  IREQ[4:0], IRQ
)
```

---

## References

- SPI: OpenCores SPI IP Core
- GPIO: OpenCores GPIO Project  
- UART: OpenCores UART16550 Project
- AHB/APB: ARM AMBA Specification
