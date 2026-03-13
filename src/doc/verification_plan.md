# Plan de Verificación - UVM Cookbook Examples

## 1. Resumen Ejecutivo

Este documento presenta el plan de verificación para los ejemplos del UVM Cookbook, que incluyen entornos de verificación para múltiples bloques de IP (SPI, GPIO, UART, AHB, APB) y un subsistema de nivel superior (PSS).

---

## 2. Interfaces Disponibles

### 2.1 APB (Advanced Peripheral Bus)

```
interface apb_if(
  input PCLK,        // Reloj del bus
  input PRESETn       // Reset activo bajo
);
  logic[31:0] PADDR;   // Dirección
  logic[31:0] PRDATA;  // Datos de lectura
  logic[31:0] PWDATA;  // Datos de escritura
  logic[15:0] PSEL;    // Selección de periférico
  logic PENABLE;       // Habilitación
  logic PWRITE;        // Write/Read
  logic PREADY;        // Listo
endinterface
```

**Propiedades:**
- Validación de PSEL con propiedad SVA
- Cobertura de PSEL

---

### 2.2 SPI (Serial Peripheral Interface)

```
interface spi_if;
  logic clk;           // Reloj SPI
  logic[7:0] cs;       // Chip Select (8 dispositivos)
  logic miso;          // Master In Slave Out
  logic mosi;          // Master Out Slave In
endinterface
```

---

### 2.3 GPIO (General Purpose Input/Output)

```
interface gpio_if;
  logic clk;           // Reloj
  logic[31:0] gpio;    // 32 pines GPIO
  bit ext_clk;         // Clock externo para muestreo
endinterface
```

---

### 2.4 AHB (Advanced High-performance Bus)

```
interface ahb_if(
  input HCLK,          // Reloj
  input HRESETn        // Reset activo bajo
);
  logic [31:0] HADDR;    // Dirección
  logic [1:0] HTRANS;    // Tipo de transferencia
  logic HWRITE;          // Write/Read
  logic [2:0] HSIZE;    // Tamaño de datos
  logic [2:0] HBURST;   // Tipo de ráfaga
  logic [3:0] HPROT;    // Protección
  logic [31:0] HWDATA;  // Datos de escritura
  logic [31:0] HRDATA;  // Datos de lectura
  logic [1:0] HRESP;    // Respuesta
  logic HREADY;          // Listo
  logic HSEL;            // Selección
endinterface
```

---

### 2.5 UART (Universal Asynchronous Receiver/Transmitter)

```
interface serial_if;
  logic sdata;         // Datos serie
  logic clk;           // Reloj
endinterface
```

---

### 2.6 Interrupciones

```
interface intr_if;
  logic IRQ;           // Línea de interrupción
  logic[7:0] IREQ;     // Solicitudes de interrupción (8 fuentes)
endinterface
```

---

## 3. VIP (Verification IP) Implementados

### 3.1 APB Agent

**Componentes:**
- `apb_agent` - Agent principal
- `apb_driver` - Driver del bus APB
- `apb_monitor` - Monitor del bus APB
- `apb_sequencer` - Sequencer para secuencias
- `apb_coverage_monitor` - Monitor de cobertura funcional
- `apb_agent_config` - Configuración del agente
- `reg2apb_adapter` - Adaptador para register layer

**Modos:** ACTIVE / PASSIVE (configurable)

---

### 3.2 SPI Agent

**Componentes:**
- `spi_agent` - Agent principal
- `spi_driver` - Driver SPI
- `spi_monitor` - Monitor SPI
- `spi_sequencer` - Sequencer
- `spi_agent_config` - Configuración
- `spi_seq_item` - Item de transacción

**Características:**
- Soporte para múltiples chip selects (8)
- Modo full duplex

---

### 3.3 GPIO Agent

**Componentes:**
- `gpio_agent` - Agent principal
- `gpio_driver` - Driver GPIO
- `gpio_monitor` - Monitor GPIO
- `gpio_sequencer` - Sequencer
- `gpio_agent_config` - Configuración
- `gpio_seq_item` - Item de transacción

**Características:**
- Dos puertos de análisis: `ap` y `ext_ap`
- Soporte para clock externo

---

### 3.4 AHB Agent

**Componentes:**
- `ahb_agent` - Agent principal
- `ahb_driver` - Driver AHB
- `ahb_monitor` - Monitor AHB
- `ahb_sequencer` - Sequencer
- `ahb_agent_config` - Configuración
- `reg2ahb_adapter` - Adaptador register layer

**Características:**
- Soporte para bursts y transacciones
- Configurable para ACTIVE/PASSIVE

---

### 3.5 UART Agent

**Componentes:**
- `uart_agent` - Agent principal
- `uart_driver` - Driver UART
- `uart_monitor` - Monitor UART
- `uart_agent_config` - Configuración

---

### 3.6 Modem Agent

**Componentes:**
- `modem_agent` - Agent principal
- `modem_driver` - Driver
- `modem_monitor` - Monitor
- `modem_coverage_monitor` - Cobertura
- `modem_basic_sequence` - Secuencia base

---

### 3.7 Utility - Interrupt Utils

**Componentes:**
- `intr_util` - Utilidad para manejo de interrupciones
- `intr_bfm` - BFM para interrupciones
- `intr_if` - Interface de interrupciones

---

## 4. Ambientes de Verificación

### 4.1 SPI Testbench (Block Level)

```
spi_env
├── apb_agent          (ACTIVE) - Configuración de registros
├── spi_agent          (ACTIVE) - Transferencias SPI
├── spi_scoreboard     - Verificación de datos
├── reg2apb_adapter    - Registro layer
└── m_apb2reg_predictor - Predictor explícito
```

**Registro Model:** spi_reg_pkg

---

### 4.2 GPIO Testbench (Block Level)

```
gpio_env
├── apb_agent          (ACTIVE) - Configuración de registros
├── m_GPO_agent       - GPIO Output
├── m_GPOE_agent      - GPIO Output Enable
├── m_GPI_agent       - GPIO Input
├── m_AUX_agent       - GPIO Aux
├── gpio_out_scoreboard - Scoreboard salidas
├── gpio_in_scoreboard  - Scoreboard entradas
├── reg2apb_adapter
└── m_apb2reg_predictor
```

**Registro Model:** gpio_reg_pkg

---

### 4.3 PSS Subsystem Testbench

```
pss_env
├── spi_env           - Ambiente SPI
│   ├── apb_agent
│   ├── spi_agent
│   └── spi_scoreboard
├── gpio_env          - Ambiente GPIO
│   ├── apb_agent
│   ├── m_GPO_agent
│   ├── m_GPI_agent
│   └── scoreboards
├── ahb_agent         (ACTIVE) - Bus AHB sistema
├── reg2ahb_adapter
└── m_ahb2reg_predictor
```

**Registro Model:** pss_reg_pkg (Modelo jerárquico)

---

## 5. Diagramas de Arquitectura

### 5.1 Arquitectura General de Verificación

```
                    +------------------+
                    |   Test Base      |
                    +--------+---------+
                             |
                    +--------v---------+
                    |    Test Case     |
                    +--------+---------+
                             |
                    +--------v---------+
                    |    Environment   |
                    |   (uvm_env)      |
                    +--------+---------+
                             |
        +--------------------+--------------------+
        |                    |                    |
+-------v-------+    +--------v--------+    +-----v------+
|   APB Agent   |    |   SPI/GPIO      |    |   AHB      |
| (Bus Monitor) |    |    Agents       |    |   Agent    |
+---------------+    +-----------------+    +------------+
        |                    |                    |
        +--------------------+--------------------+
                             |
                    +--------v---------+
                    |   Scoreboard    |
                    |   + Reg Model   |
                    +-----------------+
```

### 5.2 Conexiones RTL a VIP

```
+--------+      +----------+      +--------+      +---------+
|  RTL   |<---->|  BFM    |<---->| Driver |<---->| Sequencer
|  DUT   |      | (VIP)   |      |  (VIP) |      |  (UVM)  |
+--------+      +----------+      +--------+      +---------+
                     |                                     |
                     +---------------+---------------------+
                                     |
                            +--------v---------+
                            |    Monitor       |
                            |    (UVM)         |
                            +--------+---------+
                                     |
                    +----------------+----------------+
                    |                                 |
           +--------v--------+             +--------v--------+
           |   Scoreboard    |             |   Coverage     |
           +-----------------+             +-----------------+
```

---

## 6. Testcases Implementados

### 6.1 SPI Testbench

| Testcase | Descripción | Método de Verificación |
|----------|-------------|------------------------|
| `spi_interrupt_test` | Configuración y manejo de interrupciones SPI | Secuencia `config_interrupt_test`, coverage UVM |
| `spi_poll_test` | Verificación por polling de flags | Secuencia `config_polling_test` |
| `spi_reg_test` | Verificación de registros (reset, acceso) | `register_test_vseq`, verifica 7 resets de registros |

**Qué se testea:**
- Transferencias SPI full-duplex
- Configuración de registros via APB
- Flags de status (TXE, RXNE)
- Interrupciones (TXEIE, RXNEIE)
- Reset de hardware de registros

---

### 6.2 GPIO Testbench

| Testcase | Descripción | Método de Verificación |
|----------|-------------|------------------------|
| `gpio_outputs_test` | Escritura a pines GPIO de salida | Scoreboard: GPO → RTL → Scoreboard |
| `gpio_input_test` | Lectura de pines GPIO de entrada | Scoreboard: RTL → GPI → Scoreboard |
| `gpio_reg_test` | Verificación de registros | `reg_test_vseq` |

**Qué se testea:**
- Escritura a registros de salida (GPO)
- Habilitación de salidas (GPOE)
- Lectura de pines de entrada (GPI)
- Pines auxiliary (AUX)
- Integración con APB para configuración de registros

---

### 6.3 PSS Subsystem Testbench

| Testcase | Descripción | Método de Verificación |
|----------|-------------|------------------------|
| `pss_spi_interrupt_test` | Integración SPI en subsystem | 10 iteraciones de `spi_int_vseq` |
| `pss_gpio_outputs_test` | Integración GPIO en subsystem | 10 iteraciones de `GPO_test_vseq` |

**Qué se testea:**
- Integración de múltiples bloques (SPI + GPIO)
- Comunicación AHB → APB bridge
- Modelo de registros jerárquico
- Interrupciones a nivel de sistema

---

## 7. Plan de Cobertura

### 7.1 Cobertura Funcional Implementada

| Tipo | Agent | Descripción |
|------|-------|-------------|
| Coverage | APB | Covergroup en `apb_coverage_monitor` |
| Coverage | GPIO | Monitoreo de transiciones en pines |
| Coverage | Modem | `modem_coverage_monitor` |
| Register | Todos | UVM Register Model con predictor explícito |

### 7.2 Coverage Points Sugeridos (No implementados)

- **Cobertura de protocolo SPI:** Modos (0-3), velocidad, longitud de datos
- **Cobertura de protocolo UART:** Baud rate, parity, stop bits
- **Cobertura de interrupciones:** Todas las fuentes de IRQ

---

## 8. Directorio de Archivos

### VIP Location
```
src/vip/
├── agents/
│   ├── apb_agent/
│   ├── ahb_agent/
│   ├── spi_agent/
│   ├── gpio_agent/
│   ├── uart_agent/
│   └── modem_agent/
└── utils/
    └── interrupt/
```

### Testbench Location
```
src/tb/
├── block_level_tbs/
│   ├── spi_tb/
│   │   ├── env/
│   │   ├── test/
│   │   ├── sequences/
│   │   ├── register_model/
│   │   └── tb/
│   └── gpio_tb/
│       ├── env/
│       ├── test/
│       ├── sequences/
│       ├── register_model/
│       └── tb/
└── sub_system_tbs/
    └── pss_tb/
        ├── env/
        ├── test/
        ├── sequences/
        ├── register_model/
        └── tb/
```

### RTL Location
```
src/rtl/
├── spi/
├── gpio/
├── uart/
├── pss/
├── icpit/
└── ahb2apb/
```

---

## 9. Ejecución de Tests

### SPI Testbench
```bash
cd src/tb/block_level_tbs/spi_tb/sim
make all              # Build y run test por defecto
make run              # Run test por defecto
TEST=spi_poll_test make run  # Test específico
```

### GPIO Testbench
```bash
cd src/tb/block_level_tbs/gpio_tb/sim
make all
TEST=gpio_input_test make run
```

### PSS Testbench
```bash
cd src/tb/sub_system_tbs/pss_tb/sim
make all
TEST=pss_gpio_outputs_test make run
```

---

## 10. Resumen

| Bloque | Testbench | Agents | Scoreboard | Reg Model |
|--------|-----------|--------|------------|-----------|
| SPI | ✓ Block Level | APB + SPI | ✓ | ✓ |
| GPIO | ✓ Block Level | APB + GPIO(x4) | ✓ In/Out | ✓ |
| PSS | ✓ Subsystem | AHB + SPI + GPIO | ✓ | ✓ |

**VIPs disponibles pero no utilizados en tests:**
- UART Agent
- Modem Agent
- AHB Agent (solo en PSS)

---

*Documento generado automáticamente basado en el análisis del código fuente UVM.*
