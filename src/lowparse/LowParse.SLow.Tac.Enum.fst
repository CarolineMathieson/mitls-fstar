module LowParse.SLow.Tac.Enum
include LowParse.SLow.Enum

module T = LowParse.TacLib

noextract
let rec enum_tac_gen
  (t_cons_nil: T.term)
  (t_cons: T.term)
  (#key #repr: Type)
  (e: list (key * repr))
: T.Tac unit
= match e with
  | [] -> T.fail "enum_tac_gen: e must be cons"
  | [_] ->
    T.apply t_cons_nil;
    T.iseq [
      T.solve_vc;
      T.solve_vc;
    ];
    T.qed ()
  | _ :: e_ ->
    T.apply t_cons;
    T.iseq [
      T.solve_vc;
      (fun () -> enum_tac_gen t_cons_nil t_cons e_);
    ];
    T.qed ()

noextract
let maybe_enum_key_of_repr_tac
  (#key #repr: Type)
  (e: list (key * repr))
: T.Tac unit
= enum_tac_gen (quote maybe_enum_key_of_repr'_t_cons_nil') (quote maybe_enum_key_of_repr'_t_cons') e

noextract
let enum_repr_of_key_tac
  (#key #repr: Type)
  (e: list (key * repr))
: T.Tac unit
= enum_tac_gen (quote enum_repr_of_key_cons_nil') (quote enum_repr_of_key_cons') e

noextract
let parse32_maybe_enum_key_tac
  (#k: parser_kind)
  (#key #repr: eqtype)
  (#p: parser k repr)
  (p32: parser32 p)
  (e: enum key repr { Cons? e } )
  (#k' : parser_kind)
  (p' : parser k' (maybe_enum_key e))
  (u: unit {
    k' == k /\
    p' == parse_maybe_enum_key p e
  })
  ()
: T.Tac unit
= let fu = quote (parse32_maybe_enum_key_gen #k #key #repr #p p32 e) in
  T.apply fu;
  T.iseq [
    T.solve_vc;
    T.solve_vc;
    T.solve_vc;
    (fun () -> maybe_enum_key_of_repr_tac #key #repr e);
  ]

noextract
let parse32_enum_key_tac
  (#k: parser_kind)
  (#key #repr: eqtype)
  (#p: parser k repr)
  (p32: parser32 p)
  (e: enum key repr { Cons? e } )
  (#k' : parser_kind)
  (p' : parser k' (enum_key e))
  (u: unit {
    k' == parse_filter_kind k /\
    p' == parse_enum_key p e
  })
  ()
: T.Tac unit
= let fu = quote (parse32_enum_key_gen #k #key #repr p e) in
  T.apply fu;
  T.iseq [
    T.solve_vc;
    T.solve_vc;
    T.solve_vc;
    (fun () -> parse32_maybe_enum_key_tac p32 e (parse_maybe_enum_key p e) () ())
  ]

noextract
let serialize32_enum_key_gen_tac
  (#k: parser_kind)
  (#key #repr: eqtype)
  (#p: parser k repr)
  (#s: serializer p)
  (s32: serializer32 s)
  (e: enum key repr { Cons? e } )
  (#k' : parser_kind)
  (#p' : parser k' (enum_key e))
  (s' : serializer p')
  (u: unit {
    k' == parse_filter_kind k /\
    p' == parse_enum_key p e /\
    s' == serialize_enum_key p s e
  })
  ()
: T.Tac unit
= let fu = quote (serialize32_enum_key_gen #k #key #repr #p #s s32 e) in
  T.apply fu;
  T.iseq [
    T.solve_vc;
    T.solve_vc;
    T.solve_vc;
    T.solve_vc;
    (fun () -> enum_repr_of_key_tac e);
  ]

noextract
let serialize32_maybe_enum_key_tac
  (#k: parser_kind)
  (#key #repr: eqtype)
  (#p: parser k repr)
  (#s: serializer p)
  (s32: serializer32 s)
  (e: enum key repr { Cons? e } )
  (#k' : parser_kind)
  (#p' : parser k' (maybe_enum_key e))
  (s' : serializer p')
  (u: unit {
    k == k' /\
    p' == parse_maybe_enum_key p e /\
    s' == serialize_maybe_enum_key p s e
  })
  ()
: T.Tac unit
= let fu = quote (serialize32_maybe_enum_key_gen #k #key #repr #p #s s32 e) in
  T.apply fu;
  T.iseq [
    T.solve_vc;
    T.solve_vc;
    T.solve_vc;
    T.solve_vc;
    (fun () -> enum_repr_of_key_tac e);
  ]
