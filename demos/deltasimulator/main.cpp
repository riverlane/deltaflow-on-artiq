#include "rabi_demo.h"
#include <iostream>
#include <systemc>
#include <limits>
#include <sstream>
#include <Python.h>

using namespace std;
using namespace sc_core;
using namespace sc_dt;

int sc_main(__attribute__((unused)) int argc, __attribute__((unused)) char** argv) {
  sc_core::sc_report_handler::set_actions( "/IEEE_Std_1666/deprecated",
                                           sc_core::SC_DO_NOTHING );  
  Py_Initialize();

  cout << "hello" << endl;

  sc_trace_file *Tf;
  Tf = sc_create_vcd_trace_file("/workdir/rabi_deltaruntime_run");
  sc_clock clk("clk", sc_time(1, SC_NS));
  sc_trace(Tf, clk, "clk");
  sc_signal<bool> rst; sc_trace(Tf, rst, "rst"); rst.write(0);

  Rabi_Demo rabi("RABI", Tf);
  rabi.clk.bind(clk);
  rabi.rst.bind(rst);

  rst.write(1);
  sc_start(5, SC_NS);
  rst.write(0);

  try {
    sc_start(1000, SC_NS);
    sc_close_vcd_trace_file(Tf);
  } catch (...){
    cout << "exiting on error" << endl;
    Py_Finalize();
    sc_close_vcd_trace_file(Tf);
    throw;
  }
  Py_Finalize();
  return 0;
}
