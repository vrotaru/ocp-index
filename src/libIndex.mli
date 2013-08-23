(**************************************************************************)
(*                                                                        *)
(*  Copyright 2013 OCamlPro                                               *)
(*                                                                        *)
(*  All rights reserved.  This file is distributed under the terms of     *)
(*  the GNU Public License version 3.0.                                   *)
(*                                                                        *)
(*  This software is distributed in the hope that it will be useful,      *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU General Public License for more details.                          *)
(*                                                                        *)
(**************************************************************************)

(** {1 ocp-index}
    Lightweight documentation extractor for installed OCaml libraries.
    This module contains the whole API. *)

(** {2 Main types} *)

(** Lazy trie structure holding the info on all identifiers *)
type t

(** The type of files we get our data from *)
type orig_file = IndexTypes.orig_file = private
    Cmt of string | Cmti of string | Cmi of string

(** Contains the information on a given identifier *)
type info = IndexTypes.info = private {
  path: string list;
  kind: kind;
  name: string;
  ty: IndexTypes.ty option;
  loc_sig: Location.t;
  loc_impl: Location.t Lazy.t;
  doc: string option Lazy.t;
  file: orig_file;
  (* library: string option *) }

(** The kind of elements that can be stored in the trie *)
and kind = IndexTypes.kind = private
  | Type | Value | Exception
  | Field of info | Variant of info
  | Method of info
  | Module | ModuleType
  | Class | ClassType


(** {2 Utility functions} *)

module Misc: sig
  (** Helper function, useful to lookup all subdirs of a given path before
      calling [load] *)
  val unique_subdirs: string list -> string list
end


(** {2 Building} *)

(** Build the trie from a list of include directories. They will be scanned for
    [.cmi] and [.cmt] files to complete on module names, and the contents of
    these files will be lazily read whenever needed. *)
val load: string list -> t

(** Load a single file into a trie *)
val add_file: t -> string -> t

(** Consider the module at the given path as opened, i.e. rebind its contents at
    the root of the trie. If [cleanup_path], also change its contents to refer
    to the new path. *)
val open_module: ?cleanup_path:bool -> t -> string list -> t

(** Same as [open_module], but tries to open even the elements that are not in
    the external interface (this needs a cmt to be present) *)
val fully_open_module: ?cleanup_path:bool -> t -> string list -> t

(** [alias t origin alias] binds at [alias] the contents found at [origin]. If
    [~cleanup_path] is set, also change its contents to refer to the new
    path. *)
val alias: ?cleanup_path:bool -> t -> string list -> string list -> t

(** {2 Querying} *)

(** Returns all bindings in the trie *)
val all: t -> info list

(** Lookup an identifier in a trie (eg. [option] or [List.map]) *)
val get: t -> string -> info

(** Lookup identifiers starting with the given string. Completion stops at
    module boundaries (it wont unfold contents of modules) *)
val complete: t -> ?filter:(info -> bool) -> string -> info list


(** {2 Output} *)

include module type of IndexOut
