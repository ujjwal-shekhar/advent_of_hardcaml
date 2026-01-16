open! Base
open! Hardcaml
open! Day3

let () =
  let scope = Scope.create ~name:"day3_part1" () in
  let module Circuit = Circuit.With_interface(Part1.I)(Part1.O) in
  let circuit = Circuit.create_exn ~name:"day3_part1" (Part1.create scope) in
  Rtl.print Verilog circuit