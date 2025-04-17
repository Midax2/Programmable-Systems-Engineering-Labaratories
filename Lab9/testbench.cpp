#include "systemc.h"
#include "design.h"

int sc_main(int argc, char* argv[]) {
    sc_signal<bool> clk_i;
    sc_signal<bool> rst_i;
    sc_signal<sc_uint<3>> led_o;

    // Instancja licznika
    gray_counter counter("GRAY_COUNTER");
    counter.clk_i(clk_i);
    counter.rst_i(rst_i);
    counter.led_o(led_o);

    // Plik VCD
    sc_trace_file* wf = sc_create_vcd_trace_file("gray_wave");
    sc_trace(wf, clk_i, "clk_i");
    sc_trace(wf, rst_i, "rst_i");
    sc_trace(wf, led_o, "led_o");

    // Reset początkowy
    rst_i = 1;
    sc_start(10, SC_NS);

    rst_i = 0;

    // Symulacja zegara
    for (int i = 0; i < 20; i++) {
        clk_i = 0;
        sc_start(10, SC_NS);
        clk_i = 1;
        sc_start(10, SC_NS);
    }

    sc_close_vcd_trace_file(wf);
    return 0;
}
