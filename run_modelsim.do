vlib work
vmap work work

vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/SequenceItem.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Sequencer.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Sequence.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Monitor.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Driver.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Agent.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Scoreboard.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/CoverageCollector.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Env.sv
vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/Test.sv

vlog -sv +incdir+Verification_SV_UVMlike Verification_SV_UVMlike/tb.sv


vsim tb
run -all
quit
