open Repr
open Feature

type primitive_entry = {
  prim_name : string;
  prim_type : type_repr;
  prim_may_raise : bool;
  prim_loc : Location.t;
}

type function_entry = {
  func_name : string;
  func_type : type_repr;
  func_model : string option;
  func_may_raise : bool;
  func_loc : Location.t;
}

type variant_entry = {
  variant_name : string;
  variant_args: mono_type_repr list;
}

type type_value =
  | Variant of variant_entry list
  | Opaque

type type_entry = {
  type_name : string;
  type_params : string list;
  type_model : string option;
  type_value : type_value;
  type_loc : Location.t;
}

type mutually_recursive_types_entry = type_entry list

type exception_entry = {
  exception_name : string;
  exception_args : mono_type_repr list;
  exception_loc : Location.t;
}

type module_entry = {
  mod_namespace : string list;
  mod_name : string;
  mod_intro : intro_entry list;
  mod_functions : function_entry list;
  mod_primitives : primitive_entry list;
  mod_exceptions : exception_entry list;
  mod_loc : Location.t;
}

and intro_entry =
  | IntroType of type_entry
  | IntroMod of module_entry

type entry =
  | EPrim of primitive_entry
  | EFunc of function_entry
  | EType of type_entry
  | EExn of exception_entry
  | EMod of module_entry

val module_of_signatures : ?loc:(Location.t option) -> features -> string list -> string -> Types.signature -> module_entry

val dependencies : type_entry -> string list

val find_mutually_recursive_types
  : type_entry list -> mutually_recursive_types_entry list

val translate_function : Translation.t -> function_entry -> function_entry
val translate_primitive : Translation.t -> primitive_entry -> primitive_entry
val translate_exception : Translation.t -> exception_entry -> exception_entry
val translate_type : Translation.t -> type_entry -> type_entry
