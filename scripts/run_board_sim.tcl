set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize [file join $script_dir ..]]

open_project [file join $project_dir FFT_Project.xpr]

# Generated output products are intentionally not committed.
generate_target all [get_ips blk_mem_gen_0]
export_ip_user_files -of_objects [get_ips blk_mem_gen_0] -no_script -sync -force -quiet

foreach testbench {board_pipeline_tb display_tb} {
    puts "Running $testbench"
    set_property top $testbench [get_filesets sim_1]
    reset_simulation sim_1
    launch_simulation -simset sim_1 -mode behavioral
    close_sim
}

close_project
exit
