open! Base
open! Hardcaml
open! Day3

let run () =
  (* Create Simulator for Part 1 *)
  let module Sim1 = Cyclesim.With_interface(Part1.I)(Part1.O) in
  let sim1 = Sim1.create (Part1.create (Scope.create ~name:"part1" ())) in
  let inputs1 = Cyclesim.inputs sim1 in
  let outputs1 = Cyclesim.outputs sim1 in

  (* Create Simulator for Part 2 *)
  let module Sim2 = Cyclesim.With_interface(Part2.I)(Part2.O) in
  let sim2 = Sim2.create (Part2.create (Scope.create ~name:"part2" ())) in
  let inputs2 = Cyclesim.inputs sim2 in
  let outputs2 = Cyclesim.outputs sim2 in

  (* Helper to drive inputs on both sims *)
  let set_inputs f = 
    f inputs1; 
    f inputs2 
  in
  
  let cycle () = 
    Cyclesim.cycle sim1; 
    Cyclesim.cycle sim2 
  in

  (* Reset *)
  set_inputs (fun i -> i.reset := Bits.vdd);
  cycle ();
  set_inputs (fun i -> i.reset := Bits.gnd);

  (* Read File *)
  let content = Stdio.In_channel.read_all "data/day3_input.txt" in
  
  String.iter content ~f:(fun c ->
    set_inputs (fun i -> 
      i.is_valid := Bits.gnd;
      i.is_nl := Bits.gnd
    );

    if Char.is_digit c then (
      set_inputs (fun i -> 
        i.char_in := Bits.of_char c;
        i.is_valid := Bits.vdd
      );
    ) else if Char.equal c '\n' then (
      set_inputs (fun i -> i.is_nl := Bits.vdd);
    );
    cycle ()
  );

  (* Final newline pulse *)
  set_inputs (fun i -> 
    i.is_valid := Bits.gnd;
    i.is_nl := Bits.vdd
  );
  cycle ();

  let result1 = Bits.to_int64 !(outputs1.total_ans) in
  let result2 = Bits.to_int64 !(outputs2.total_ans) in
  
  Stdio.printf "Day 3 Part 1 Result: %Ld\n" result1;
  Stdio.printf "Day 3 Part 2 Result: %Ld\n" result2

let () = run ()