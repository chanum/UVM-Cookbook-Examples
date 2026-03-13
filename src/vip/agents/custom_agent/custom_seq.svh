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
class custom_base_seq extends uvm_sequence #(custom_seq_item);

  `uvm_object_utils(custom_base_seq)

  extern function new(string name = "custom_base_seq");

endclass: custom_base_seq

function custom_base_seq::new(string name = "custom_base_seq");
  super.new(name);
endfunction


class custom_read_seq extends uvm_sequence #(custom_seq_item);

  `uvm_object_utils(custom_read_seq)

  rand logic[31:0] addr;

  extern function new(string name = "custom_read_seq");
  extern task body;

endclass: custom_read_seq

function custom_read_seq::new(string name = "custom_read_seq");
  super.new(name);
endfunction

task custom_read_seq::body;
  req = custom_seq_item::type_id::create("req");
  start_item(req);
  req.addr = addr;
  req.read_write = 1'b1;
  req.randomize();
  finish_item(req);
endtask: body


class custom_write_seq extends uvm_sequence #(custom_seq_item);

  `uvm_object_utils(custom_write_seq)

  rand logic[31:0] addr;
  rand logic[31:0] data;

  extern function new(string name = "custom_write_seq");
  extern task body;

endclass: custom_write_seq

function custom_write_seq::new(string name = "custom_write_seq");
  super.new(name);
endfunction

task custom_write_seq::body;
  req = custom_seq_item::type_id::create("req");
  start_item(req);
  req.addr = addr;
  req.data = data;
  req.read_write = 1'b0;
  req.randomize();
  finish_item(req);
endtask: body
