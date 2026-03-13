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
class custom_agent_config extends uvm_object;

  `uvm_object_utils(custom_agent_config)

  localparam string s_my_config_id = "custom_agent_config";

  virtual custom_if vif;

  uvm_active_passive_enum active = UVM_ACTIVE;
  bit has_functional_coverage = 0;
  bit has_scoreboard = 0;

  extern function new(string name = "custom_agent_config");

endclass: custom_agent_config

function custom_agent_config::new(string name = "custom_agent_config");
  super.new(name);
endfunction
