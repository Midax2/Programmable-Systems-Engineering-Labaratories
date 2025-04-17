#include "systemc.h"

SC_MODULE(gray_counter) {
    sc_in<bool> clk_i;
    sc_in<bool> rst_i;
    sc_out<sc_uint<3>> led_o;

    sc_uint<3> b;

    void gray_process() {
        if (rst_i.read() == 1) {
            b = 0;
        }
        else if (clk_i.event() && clk_i.read() == 1) {
            b = b + 1;
        }

        // Konwersja binarnego b na kod Graya
        sc_uint<3> gray;
        gray[2] = b[2];
        gray[1] = b[2] ^ b[1];
        gray[0] = b[1] ^ b[0];
        led_o.write(gray);

        std::cout << "@" << sc_time_stamp() << " Bin: " << b << " Gray: " << gray << std::endl;
    }

    SC_CTOR(gray_counter) {
        SC_METHOD(gray_process);
        sensitive << clk_i.pos() << rst_i;
    }
};
