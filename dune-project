(lang dune 3.20)
(name advent_of_hardcaml)
(generate_opam_files true)

(package
 (name advent_of_hardcaml)
 (depends
  (ocaml (>= 5.0.0))
  dune
  base
  stdio
  hardcaml
  ppx_hardcaml
  ppx_jane))