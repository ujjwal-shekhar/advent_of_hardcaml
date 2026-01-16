open! Import
open Hardcaml
open Signal

module I = Part1.I

module O = struct
  type 'a t = {
    total_ans : 'a [@bits 64];
  } [@@deriving sexp_of, hardcaml]
end

let create (_scope : Scope.t) (i : _ I.t) =
  let spec = Reg_spec.create ~clock:i.clock ~reset:i.reset () in

  let digit_val = uresize (i.char_in -: (of_int ~width:8 48)) 4 in
  let ten = of_int ~width:4 10 in

  (* We need 12 registers. 
     From the cpp sol, regs are our dp array in some sense
     regs.(k) stores the Max Value for a subsequence of length (k+1).
     
     Since the definition of the 'next' state for reg k depends on the 
     'current' state of reg k and k-1, we first create wires for all 
     current states to close the loop.
  *)
  let current_regs = List.init 12 ~f:(fun _ -> wire 64) in

  (* The dp update simply needs the newly streamed value! *)
  let next_regs = 
    List.mapi current_regs ~f:(fun k current_reg_k ->
      
      (* The candidate value depends on the previous stage.
         If k=0 (length 1), the candidate is just the digit itself.
         If k>0, candidate is (prev_stage_max * 10) + digit. *)
      let candidate = 
        if k = 0 then 
          uresize digit_val 64
        else
          let prev_reg = List.nth_exn current_regs (k - 1) in
          (* (Prev * 10) + Digit *)
          let shifted = uresize (prev_reg *: (uresize ten 64)) 64 in
          shifted +: (uresize digit_val 64)
      in

      (*dp update*)
      let new_max = mux2 (candidate >: current_reg_k) candidate current_reg_k in
      mux2 i.is_nl (zero 64) new_max
    )
  in

  (* Accumulate the dp(11) state per row*)
  let regs = 
    List.map next_regs ~f:(fun next_val -> 
      reg spec ~enable:(i.is_valid |: i.is_nl) next_val
    ) 
  in
  List.iter2_exn current_regs regs ~f:(<==);
  let final_stage_max = List.nth_exn current_regs 11 in

  let ans_feedback = wire 64 in
  let ans = reg spec ~enable:i.is_nl (ans_feedback +: final_stage_max) in
  ans_feedback <== ans;

  { O.total_ans = ans }