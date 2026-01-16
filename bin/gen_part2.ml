open! Base
open! Hardcaml
open! Day3

let () =
  let scope = Scope.create ~name:"day3_part2" () in
  let module Circuit = Circuit.With_interface(Part2.I)(Part2.O) in
  let circuit = Circuit.create_exn ~name:"day3_part2" (Part2.create scope) in
  Rtl.print Verilog circuit