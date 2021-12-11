//------------------------------------------------------------
//   Copyright 2010-2018 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------
//
// Class Description:
//
//
class gpio_driver extends uvm_driver #(gpio_seq_item, gpio_seq_item);

// UVM Factory Registration Macro
//
`uvm_component_utils(gpio_driver)

// Virtual Interface
virtual gpio_driver_bfm m_bfm;

//------------------------------------------
// Data Members
//------------------------------------------
gpio_agent_config m_cfg;

//------------------------------------------
// Methods
//------------------------------------------

// Standard UVM Methods:
extern function new(string name = "gpio_driver", uvm_component parent = null);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

endclass: gpio_driver

function gpio_driver::new(string name = "gpio_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

function void gpio_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `get_config(gpio_agent_config, m_cfg, "gpio_agent_config")
  m_bfm = m_cfg.drv_bfm;
endfunction : build_phase

task gpio_driver::run_phase(uvm_phase phase);
  gpio_seq_item req;

  m_bfm.clear_sigs();
  forever begin
    seq_item_port.get_next_item(req);
    m_bfm.drive(req);
    seq_item_port.item_done();
  end

endtask: run_phase
