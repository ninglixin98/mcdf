
module class_encapsulation;

bit b_object_instantiation = 1;

  class chnl_trans;
    bit[31:0] data[];
    int ch_id;
    int pkt_id;
    int data_nidles;
    int pkt_nidles;
    bit rsp;
    int obj_id;
    static int global_obj_id = 0;

    function new();
      global_obj_id++;
      obj_id = global_obj_id;
    endfunction

    function chnl_trans clone();
      chnl_trans c = new();
      c.data = this.data;
      c.ch_id = this.ch_id;
      c.pkt_id = this.pkt_id;
      c.data_nidles = this.data_nidles;
      c.pkt_nidles = this.pkt_nidles;
      c.rsp = this.rsp;
      return c;
    endfunction

    function string sprint();
      string s;
      s = {s, $sformatf("obj_id = %0d: \n", this.obj_id)};
      foreach(data[i]) s = {s, $sformatf("data[%0d] = %8x \n", i, this.data[i])};
      s = {s, $sformatf("ch_id = %0d: \n", this.ch_id)};
      s = {s, $sformatf("pkt_id = %0d: \n", this.pkt_id)};
      s = {s, $sformatf("data_nidles = %0d: \n", this.data_nidles)};
      s = {s, $sformatf("pkt_nidles = %0d: \n", this.pkt_nidles)};
      s = {s, $sformatf("rsp = %0d: \n", this.rsp)};
      return s;
    endfunction
  endclass: chnl_trans

// TODO-1 learn the object instantiation
// TODO-2 learn the handle pointting to an object
// TODO-3 learn the class function clone()/sprint()
// TODO-4 compare if t1, t2 and t3 are pointting to the same object?
// TODO-5 check if the t1 pointted object data is exactly the same with the t3
//        pointted object?
// TODO-6 learn how to call STATIC member variable/function, and their
//        difference with local member variable/function
initial begin: object_instantiation
  chnl_trans t1, t2, t3;
  wait(b_object_instantiation == 1); $display("b_object_instantiation process block started");
  t1 = new();
  t1.data = '{1, 2, 3, 4};
  t1.ch_id = 2;
  t1.pkt_id = 100;
  t2 = t1;
  $display("t1 object content is as below:\n%s", t1.sprint());
  $display("t2 object content is as below:\n%s", t2.sprint());
  t3 = t1.clone();
  $display("t3 object content is as below:\n%s", t3.sprint());

  $display("t1 object ID is [%0d]", t1.obj_id);
  $display("t2 object ID is [%0d]", t2.obj_id);
  $display("t3 object ID is [%0d]", t3.obj_id);
  $display("the latest chnl_trans object iD is [%0d]", chnl_trans::global_obj_id);
end

endmodule
