
module class_inheritance;

bit b_member_override = 1;

  class trans;
    bit[31:0] data[];
    int pkt_id;
    int data_nidles;
    int pkt_nidles;
    bit rsp;

    function trans clone(trans t = null);
      if(t == null) t = new();
      t.data = data;
      t.pkt_id = pkt_id;
      t.data_nidles = data_nidles;
      t.pkt_nidles = pkt_nidles;
      t.rsp = rsp;
      return t;
    endfunction
  endclass

  class chnl_trans extends trans;
    int ch_id; // new member in child class

    // member function override with 
    // same function name, arguments, and return type

    // TODO-1 seperately enable the clone function-1 and function-2, and check
    // if both of them works, and compare which is better, and why?
    // clone function-1
    function trans clone(trans t = null);
      chnl_trans ct;
      if(t == null) 
        ct = new();
      else
        void'($cast(ct, t));
      ct.data = data;
      ct.pkt_id = pkt_id;
      ct.data_nidles = data_nidles;
      ct.pkt_nidles = pkt_nidles;
      ct.rsp = rsp;
      ct.ch_id = ch_id; // new member
      return ct;
    endfunction

    // clone function-2
    // function trans clone(trans t = null);
    //   chnl_trans ct;
    //   if(t == null) 
    //     ct = new();
    //   else
    //     void'($cast(ct, t));
    //   void'(super.clone(ct));
    //   ct.ch_id = ch_id; // new member
    //   return ct;
    // endfunction
  endclass

  initial begin: member_override
    trans t1, t2;
    chnl_trans ct1, ct2;
    wait(b_member_override == 1); $display("b_member_override process block started");

    ct1 = new();
    ct1.pkt_id = 200;
    ct1.ch_id = 2;
    // t1 pointed to ct1's trans class data base
    t1 = ct1;

    // t2 copied ct1's trans class data base
    t2 = ct1.clone();
    void'($cast(ct2, t2));
    // TODO-2 why could not clone t1(->ct1) to t2?
    // t2 = t1.clone(); // ERROR clone call
    // void'($cast(ct2, t2));

    $display("ct1.pkt_id = %0d, ct1.ch_id = %0d", ct1.pkt_id, ct1.ch_id);

    // TODO-3 uncomment the statement below and consider
    //        why t1 could not point to ct1.ch_id?
    // $display("ct1.pkt_id = %0d, ct1.ch_id = %0d", t1.pkt_id, t1.ch_id);

    $display("ct2.pkt_id = %0d, ct2.ch_id = %0d", ct2.pkt_id, ct2.ch_id);
  end

endmodule
