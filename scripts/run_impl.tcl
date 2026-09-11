set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize [file join $script_dir ..]]
set build_dir [file join $project_dir build]

file mkdir $build_dir
open_project [file join $project_dir FFT_Project.xpr]

generate_target all [get_ips]
export_ip_user_files -of_objects [get_ips] -no_script -sync -force -quiet

synth_design -top top -part xc7s50csga324-1
opt_design
place_design
phys_opt_design
route_design

report_utilization -file [file join $build_dir utilization.rpt]
report_timing_summary -delay_type min_max -check_timing_verbose \
    -file [file join $build_dir timing_summary.rpt]
report_clock_interaction -file [file join $build_dir clock_interaction.rpt]
report_cdc -file [file join $build_dir cdc.rpt]
report_drc -file [file join $build_dir drc.rpt]
report_methodology -file [file join $build_dir methodology.rpt]
report_route_status -file [file join $build_dir route_status.rpt]
write_checkpoint -force [file join $build_dir top_routed.dcp]

set setup_path [get_timing_paths -delay_type max -max_paths 1]
set hold_path [get_timing_paths -delay_type min -max_paths 1]
if {[llength $setup_path] == 0 || [llength $hold_path] == 0} {
    error "timing analysis returned no setup or hold paths"
}

set setup_slack [get_property SLACK $setup_path]
set hold_slack [get_property SLACK $hold_path]
if {$setup_slack < 0.0} {
    error "setup timing failed: worst slack is $setup_slack ns"
}
if {$hold_slack < 0.0} {
    error "hold timing failed: worst slack is $hold_slack ns"
}

set severe_drc [get_drc_violations -quiet -filter {
    SEVERITY == "Error" || SEVERITY == "Critical Warning"
}]
if {[llength $severe_drc] != 0} {
    error "implementation has severe DRC violations: $severe_drc"
}

set severe_methodology [get_methodology_violations -quiet -filter {
    SEVERITY == "Error" || SEVERITY == "Critical Warning"
}]
if {[llength $severe_methodology] != 0} {
    error "implementation has severe methodology violations: $severe_methodology"
}

write_bitstream -force [file join $build_dir fft_visualizer.bit]

puts "Implementation completed successfully."
puts "Worst setup slack: $setup_slack ns"
puts "Worst hold slack: $hold_slack ns"

close_project
exit
