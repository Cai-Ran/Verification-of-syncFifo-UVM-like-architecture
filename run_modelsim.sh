rm -rf ./work
rm -rf *.log
# vsim -c -do run_modelsim.do | tee run_modelsim.log

declare -a configs=(
    "4 4 3 1"
    "8 128 8 4"
    "32 256 9 8"
    "64 1024 11 1023"
    "64 1024 11 1"
    "1 4 3 1"
    "4 2 2 1"
    "4 2 2 0"
    "8 16 5 0"
    "8 16 5 16"
    "8 16 5 17"
    "8 16 5 31"
)


for cfg in "${configs[@]}"; do
    set -- $cfg
    DW=$1; DEPTH=$2; PTR=$3; MARGIN=$4

    vlib work
    map work work


    vlog -sv \
        +define+DWIDTH=$DW \
        +define+FIFO_DEPTH=$DEPTH \
        +define+PTR_WIDTH=$PTR \
        +define+MARGIN=$MARGIN \
        +incdir+Verification_SV_UVMlike \
        Verification_SV_UVMlike/SequenceItem.sv \
        Verification_SV_UVMlike/Sequencer.sv \
        Verification_SV_UVMlike/Sequence.sv \
        Verification_SV_UVMlike/Monitor.sv \
        Verification_SV_UVMlike/Driver.sv \
        Verification_SV_UVMlike/Agent.sv \
        Verification_SV_UVMlike/Scoreboard.sv \
        Verification_SV_UVMlike/CoverageCollector.sv \
        Verification_SV_UVMlike/Env.sv \
        Verification_SV_UVMlike/Test.sv \
        Verification_SV_UVMlike/tb.sv

        echo "=== Running simulation: DW=${DW}, DEPTH=${DEPTH}, PTR=${PTR}, MARGIN=${MARGIN} ==="
        vsim -c work.tb -do "run -all; quit"  > fifo_${DW}_${DEPTH}_${PTR}_${MARGIN}.log
done

