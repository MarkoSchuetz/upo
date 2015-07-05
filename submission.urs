(* Basic abstraction of submitting files associated with some database key *)

functor Make(M : sig
                 (* Table that provides the key we submit to *)
                 con key1 :: Name
                 con keyT :: Type
                 con keyR :: {Type}
                 constraint [key1] ~ keyR
                 con key = [key1 = keyT] ++ keyR
                 constraint [Filename, Content, MimeType, When] ~ key
                 con other :: {Type}
                 constraint other ~ key
                 con keyName :: Name
                 con otherConstraints :: {{Unit}}
                 constraint [keyName] ~ otherConstraints
                 val tab : sql_table (key ++ other) ([keyName = map (fn _ => ()) key] ++ otherConstraints)
                 val keyInj : $(map sql_injectable_prim key)
                 val keyFl : folder key
                 val keyShow : show $key

                 (* Table of users *)
                 con ukey :: Name
                 con uother :: {Type}
                 con ukeyName :: Name
                 con uotherConstraints :: {{Unit}}
                 constraint [ukeyName] ~ uotherConstraints
                 constraint [ukey] ~ [Filename, Content, MimeType, When]
                 constraint [ukey] ~ uother
                 constraint [ukey] ~ key
                 val user : sql_table ([ukey = string] ++ uother) ([ukeyName = [ukey]] ++ uotherConstraints)
                 val whoami : transaction (option string)

                 (* Metadata to collect with submissions *)
                 con fs :: {(Type * Type)}
                 constraint [ukey, Filename, Content, MimeType, When] ~ fs
                 constraint key ~ fs
                 val widgets : $(map Widget.t' fs)
                 val fl : folder fs
                 val injs : $(map sql_injectable (map fst fs))
                 val labels : $(map (fn _ => string) fs)

                 val makeFilename : $key -> string (* username *) -> string
                 val mayInspect : transaction bool
             end) : sig
    val newUpload : $M.key -> transaction xbody
    (* Form to upload a new submission for a key *)

    val latests : $M.key -> transaction xbody
    (* List latest upload for each user who has made at least one, with link to view it. *)
end