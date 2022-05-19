
module array_type;

bit b_unpacked_vs_packed = 0;
bit b_array_assigment_and_loop = 0;
bit b_dynamic_array = 0;
bit b_queue_use = 0;
bit b_associate_array = 1;

// TODO-1 learn the difference between unpacked and packed data storage and
// assignment
initial begin: unpacked_vs_packed
  bit [7:0] unpacked_word [3:0];
  bit [3:0] [7:0] packed_word;
  wait(b_unpacked_vs_packed == 1); $display("unpacked_vs_packed process block started");

  // legal assignment
  unpacked_word[0] = 10;
  unpacked_word[1] = 32;
  unpacked_word[2] = 54;
  unpacked_word[3] = 76;
  $display("unpacked_word = %p", unpacked_word);

  // legal assignment with '{}
  unpacked_word = '{76, 54, 32, 10};
  $display("unpacked_word = %p", unpacked_word);

  // legal assignment
  packed_word[0] = 10;
  packed_word[1] = 32;
  packed_word[2] = 54;
  packed_word[3] = 76;
  $display("packed_word = %p", packed_word);

  // legal assignment with {} but without '
  packed_word = {8'd76, 8'd54, 8'd32, 8'd10};
  $display("packed_word = %p", packed_word);
  // legal assignment directly like a vector packedt_word[31:0]
  packed_word = (76<<24) + (54<<16) + (32<<8) + 10;
  $display("packed_word = %p", packed_word);

  // illegal assignment
  // packed_word = unpacked_word [X]
  // unpacked_word = packed_word [X]

  // illegal assignment between packed and unpacked array
  foreach(packed_word[i])
    packed_word[i] = unpacked_word[i];

  foreach(unpacked_word[i])
    unpacked_word[i] = packed_word[i];
end

// TODO-2 learn the array assignment and foreach loop indexing method
initial begin: array_assigment_and_loop
  integer sum [4][2]; // 8*4 size array 
  wait(b_array_assigment_and_loop == 1); $display("array_assigment_and_loop process block started");
  // concatenation and default value
  sum = '{0:'{'h21, 'h43}, default:'{default:'x}};
  // foreach loop indexing
  foreach(sum[i, j]) begin
    $display("sum[%0d][%0d] = 'h%0x", i, j, sum[i][j]);
  end
end

// TODO-3 learn the dynamic array basics
initial begin: dynamic_array
  int dyn1[], dyn2[];
  wait(b_dynamic_array == 1); $display("dynamic_array process block started");
  dyn1 = '{1, 2, 3, 4};
  $display("dyn1 = %p", dyn1);
  // copp method option-1
  dyn2 = dyn1;
  $display("dyn2 = %p", dyn2);
  $display("dyn2 size is %0d", dyn2.size());
  // copp method option-2
  dyn2 = new[dyn1.size()](dyn1);
  $display("dyn2 = %p", dyn2);
  $display("dyn2 size is %0d", dyn2.size());
  dyn2.delete();
  $display("dyn2 size is %0d", dyn2.size());
end

// TODO-4: learn queue use 
initial begin: queue_use
  int que1[$], que2[$];
  wait(b_queue_use == 1); $display("queue_use process block started");
  que1 = {10, 30, 40};
  $display("que1 = %p", que1);
  que2 = que1;
  $display("que2 = %p", que1);
  que1.insert(1, 20);
  $display("que1 = %p", que1);
  que1.delete(3); // delete que1[3]==40
  void'(que1.pop_front()); // pop que[0]==10
  $display("que1 = %p", que1);
  que1.delete();
  $display("que1 = %p", que1);
end


// TODO-5 learn associate array use
initial begin: associate_array
  int id_score1[int], id_score2[int]; // key ID, value SCORE
  wait(b_associate_array == 1); $display("associate_array process block started");
  id_score1[101] = 111;
  id_score1[102] = 222;
  id_score1[103] = 333;
  id_score1[104] = 444;
  id_score1[105] = 555;

  // associate array copy
  id_score2 = id_score1;
  id_score2[101] = 101;
  id_score2[102] = 102;
  id_score2[103] = 103;
  id_score2[104] = 104;
  id_score2[105] = 105;
  foreach(id_score1[id]) begin
    $display("id_score1[%0d] = %0d", id, id_score1[id]);
  end
  foreach(id_score2[id]) begin
    $display("id_score2[%0d] = %0d", id, id_score2[id]);
  end
end

endmodule
