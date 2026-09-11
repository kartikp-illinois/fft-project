set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize [file join $script_dir ..]]

open_project [file join $project_dir FFT_Project.xpr]
set_property top fft_core_tb [get_filesets sim_1]

# Generated output products are intentionally not committed.
generate_target all [get_ips blk_mem_gen_0]
export_ip_user_files -of_objects [get_ips blk_mem_gen_0] -no_script -sync -force -quiet

reset_simulation sim_1
launch_simulation -simset sim_1 -mode behavioral
close_sim
close_project
exit
