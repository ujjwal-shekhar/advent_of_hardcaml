open! Import
open Hardcaml
open Signal

module I = struct
  type 'a t = {
    clock    : 'a;
    reset    : 'a;
    char_in  : 'a [@bits 8];
    is_valid : 'a;
    is_nl    : 'a;
  } [@@deriving sexp_of, hardcaml]
end

module O = struct
  type 'a t = {
    total_ans : 'a [@bits 64];
  } [@@deriving sexp_of, hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let spec = Reg_spec.create ~clock:i.clock ~reset:i.reset () in
  
  let max_dig_feedback = wire 4 in
  let currans_feedback = wire 16 in
  let ans_feedback = wire 64 in

  (* Subtract '0' from ASCII *)
  let digit = uresize (i.char_in -: (of_int ~width:8 48)) 4 in

  (* Logic: currans = std::max(currans, 10 * max_dig + x) *)
  let combination = 
    let max_dig_16 = uresize max_dig_feedback 16 in
    let digit_16   = uresize digit 16 in
    let prod = max_dig_16 *: (of_int ~width:16 10) in 
    let sum  = prod +: uresize digit_16 32 in
    uresize sum 16
  in
  
  let currans_next = 
    mux2 (combination >: currans_feedback) combination currans_feedback
  in

  (* Registers: max_dig and currans update on is_valid, reset on is_nl *)
  let currans = reg spec ~enable:(i.is_valid |: i.is_nl) 
    (mux2 i.is_nl (zero 16) currans_next) 
  in

  let max_dig_next = mux2 (digit >: max_dig_feedback) digit max_dig_feedback in
  let max_dig = reg spec ~enable:(i.is_valid |: i.is_nl) 
    (mux2 i.is_nl (zero 4) max_dig_next) 
  in

  (* ans += currans (Triggered on newline i.e., end of the row) *)
  let ans = reg spec ~enable:i.is_nl (ans_feedback +: uresize currans 64) in

  max_dig_feedback <== max_dig;
  currans_feedback <== currans;
  ans_feedback <== ans;

  { O.total_ans = ans }