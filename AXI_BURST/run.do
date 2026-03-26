#compile
vlog ../list.svh +incdir+C:/UVM/uvm-1.2/src


#elaboaration
vsim -novopt -suppress 12110 top -sv_lib C:/questasim64_10.7c/uvm-1.2/win64/uvm_dpi 

add wave -r sim:/top/pif/*

#run
run -all
