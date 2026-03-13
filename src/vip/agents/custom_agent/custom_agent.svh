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
class custom_agent extends uvm_component;

  `uvm_component_utils(custom_agent)

  custom_agent_config m_cfg;
  custom_monitor m_monitor;
  custom_sequencer m_sequencer;
  custom_driver m_driver;

  uvm_analysis_port #(custom_seq_item) ap;

  extern function new(string name = "custom_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: custom_agent

function custom_agent::new(string name = "custom_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void custom_agent::build_phase(uvm_phase phase);
  `get_config(custom_agent_config, m_cfg, "custom_agent_config")
  
  m_monitor = custom_monitor::type_id::create("m_monitor", this);
  
  if (m_cfg.active == UVM_ACTIVE) begin
    m_driver = custom_driver::type_id::create("m_driver", this);
    m_sequencer = custom_sequencer::type_id::create("m_sequencer", this);
  end
endfunction: build_phase

function void custom_agent::connect_phase(uvm_phase phase);
  ap = m_monitor.ap;
  
  if (m_cfg.active == UVM_ACTIVE) begin
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  end
endfunction: connect_phase
