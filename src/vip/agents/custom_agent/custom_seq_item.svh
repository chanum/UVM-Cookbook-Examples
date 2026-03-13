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
class custom_seq_item extends uvm_sequence_item;

  `uvm_object_utils(custom_seq_item)

  rand logic[31:0] data;
  rand logic[31:0] addr;
  rand bit read_write;
  rand int delay;

  bit error;

  constraint delay_bounds {
    delay inside {[1:10]};
  }

  extern function new(string name = "custom_seq_item");
  extern function void do_copy(uvm_object rhs);
  extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  extern function string convert2string();

endclass: custom_seq_item

function custom_seq_item::new(string name = "custom_seq_item");
  super.new(name);
endfunction

function void custom_seq_item::do_copy(uvm_object rhs);
  custom_seq_item rhs_;
  if (!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast failed")
  end
  super.do_copy(rhs);
  data = rhs_.data;
  addr = rhs_.addr;
  read_write = rhs_.read_write;
  delay = rhs_.delay;
  error = rhs_.error;
endfunction: do_copy

function bit custom_seq_item::do_compare(uvm_object rhs, uvm_comparer comparer);
  custom_seq_item rhs_;
  if (!$cast(rhs_, rhs)) begin
    `uvm_error("do_compare", "cast failed")
    return 0;
  end
  return super.do_compare(rhs, comparer) &&
         data == rhs_.data &&
         addr == rhs_.addr &&
         read_write == rhs_.read_write;
endfunction: do_compare

function string custom_seq_item::convert2string();
  string s;
  $sformat(s, "%s\n addr=0x%h data=0x%h rw=%b delay=%0d error=%b", 
           super.convert2string(), addr, data, read_write, delay, error);
  return s;
endfunction
