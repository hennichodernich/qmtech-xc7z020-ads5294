
set core_name [lindex $argv 0]

set part_name [lindex $argv 1]

file delete -force tmp/vhdlcores/$core_name tmp/vhdlcores/$core_name.cache tmp/vhdlcores/$core_name.hw tmp/vhdlcores/$core_name.ip_user_files tmp/vhdlcores/$core_name.sim tmp/vhdlcores/$core_name.xpr

create_project -part $part_name $core_name tmp/vhdlcores

add_files -norecurse vhdlcores/$core_name.vhd

set_property TOP $core_name [current_fileset]

set files [glob -nocomplain modules/*.vhd]
if {[llength $files] > 0} {
  add_files -norecurse $files
}

ipx::package_project -root_dir tmp/vhdlcores/$core_name

set core [ipx::current_core]

set_property VERSION {1.0} $core
set_property NAME $core_name $core
set_property LIBRARY {user} $core
set_property VENDOR {hnch} $core
set_property VENDOR_DISPLAY_NAME {hennichodernich} $core
set_property COMPANY_URL {https://github.com/hennichodernich/qmtech-xc7z020-notes} $core
set_property SUPPORTED_FAMILIES {zynq Production} $core

ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::save_core $core

close_project
