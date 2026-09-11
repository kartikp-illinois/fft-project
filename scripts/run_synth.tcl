set script_dir [file dirname [file normalize [info script]]]
set project_dir [file normalize [file join $script_dir ..]]

open_project [file join $project_dir FFT_Project.xpr]

# Synthesize IP in the top-level process so this check does not depend on the
# platform-specific Vivado run launcher.
generate_target all [get_ips]
export_ip_user_files -of_objects [get_ips] -no_script -sync -force -quiet

synth_design -top top -part xc7s50csga324-1
puts "Synthesis completed successfully."

close_project
exit
