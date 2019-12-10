with TASTE.AADL_Parser;
use  TASTE.AADL_Parser;

package TASTE.Backend.Build_Script is
   --  The generation of the build script is there for legacy purpose only
   --  It is deprecated and only ensures backward compatibility with
   --  Buildsupport/Orchestrator build habits.
   --  Kazoo generates a Makefile in place of this build script.
   procedure Generate (Model : TASTE_Model);
end TASTE.Backend.Build_Script;
