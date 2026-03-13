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
class custom_driver extends uvm_driver #(custom_seq_item, custom_seq_item);

  `uvm_component_utils(custom_driver)

  virtual custom_if vif;
  custom_agent_config m_cfg;

  extern function new(string name = "custom_driver", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task drive(custom_seq_item req);

endclass: custom_driver

function custom_driver::new(string name = "custom_driver", uvm_component parent = null);
  super.new(name, parent);
endfunction

function void custom_driver::build_phase(uvm_phase phase);
  super.build_phase(phase);
  `get_config(custom_agent_config, m_cfg, "custom_agent_config")
  vif = m_cfg.vif;
endfunction: build_phase

task custom_driver::run_phase(uvm_phase phase);
  custom_seq_item req;

  forever begin
    seq_item_port.get_next_item(req);
    drive(req);
    seq_item_port.item_done();
  end

endtask: run_phase

task custom_driver::drive(custom_seq_item req);
  @(posedge vif.clk);
  #1;
  vif.valid <= 1'b1;
  vif.data <= req.data;
  
  wait(vif.ready == 1'b1);
  @(posedge vif.clk);
  vif.valid <= 1'b0;
endtask: drive
