module tb;

  int count_1 = 0;
  int count_2 = 0;

  task automatic task1;
    repeat (10) begin
      #20;
      $display("%0t : Task 1 Trigger", $time);
      count_1++;
    end
  endtask

  task automatic task2;
    repeat (5) begin
      #40;
      $display("%0t : Task 2 Trigger", $time);
      count_2++;
    end
  endtask

  initial begin
    fork
      task1();
      task2();
    join

    $display("After 200 ns:");
    $display("Task 1 count = %0d", count_1);
    $display("Task 2 count = %0d", count_2);

    $finish;
  end

endmodule
