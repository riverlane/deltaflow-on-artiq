#include <iostream>
#include <systemc>
#include <list>
#include <map>

#include "projectq_hal.hpp"

using namespace std;

struct HalBlock: sc_module {

    ProjectQHal pq_hal;

    sc_in_clk clk;
    sc_in<bool> rst;

    sc_in<sc_bv<32>> hal_command_data {"hal_command_data"};
    sc_in<sc_bv<1>> hal_command_valid {"hal_command_valid"};
    sc_out<sc_bv<1>> hal_command_ready {"hal_command_ready"};
        
    sc_out<sc_bv<32>> hal_result_data {"hal_result_data"};
    sc_out<sc_bv<1>> hal_result_valid {"hal_result_valid"};
    sc_in<sc_bv<1>> hal_result_ready {"hal_result_ready"};

    std::list<long> measurements;
    std::map<int, std::pair<std::string, bool>> cmd_mapping;

    uint32_t latency, ticks;
    uint32_t measurement_idx, readout_idx {0};

    void init_map(){
        cmd_mapping.insert({0,{"NOP", false}});
        cmd_mapping.insert({1,{"STATE_PREPARATION", false}});
        cmd_mapping.insert({2,{"STATE_MEASURE", false}});
        cmd_mapping.insert({3,{"SEND_TO_HOST", false}});
        cmd_mapping.insert({4,{"STOP", false}});
        cmd_mapping.insert({5,{"H", false}});
        cmd_mapping.insert({6,{"R", true}});
        cmd_mapping.insert({7,{"RX", true}});
        cmd_mapping.insert({8,{"RY", true}});
        cmd_mapping.insert({9,{"RZ", true}});
        cmd_mapping.insert({10,{"S",true}});
        cmd_mapping.insert({11,{"SQRT_X", false}});
        cmd_mapping.insert({12,{"T", false}});
        cmd_mapping.insert({13,{"X", false}});
        cmd_mapping.insert({14,{"Y",false}});
        cmd_mapping.insert({15,{"Z",false}});
        cmd_mapping.insert({16,{"CONTROL",false}});
        cmd_mapping.insert({24,{"OX_ION_UZZ",false}});
    }

    explicit HalBlock(sc_module_name name, uint32_t latency=0): 
        sc_module(name), latency(latency), ticks(0) {
        init_map();
        SC_METHOD(handle_hal_command);
        sensitive << hal_command_valid << hal_command_data;
        SC_METHOD(handle_hal_result);
        sensitive_pos << clk;
        dont_initialize();
    }

    SC_HAS_PROCESS(HalBlock);

    std::string parse_cmd(uint32_t word){
        int idx = (int)(word >> 26);
        std::string cmd = cmd_mapping[idx].first;
        if (cmd == "STATE_MEASURE"){
            cmd += " [#" + std::to_string(measurement_idx++) + "]"; 
        } else {
            if (cmd_mapping[idx].second){
                cmd += " (";
                cmd += std::to_string((word >> 16) & 0x1FF);
                cmd += ")";
            }
        }
        return cmd;
    }

    void handle_hal_command() {
        hal_command_ready.write(1);
        if (hal_command_valid.read() == 1) {
            uint32_t cmd = hal_command_data.read().to_uint();
            cout << sc_time_stamp() << "cmd: " << cmd << std::endl;
            uint32_t data = pq_hal.accept_command(cmd);
            cout << sc_time_stamp() << " HalBlock <- " << parse_cmd(cmd) << " - data " << std::hex << data << endl;
            if ((data >> 16) == 0xffff) { 
                measurements.push_back(data);
            }
        }
    }
      
    void handle_hal_result() {
        if (hal_result_ready.read() == 1) {
            if (!measurements.empty()){
                if (ticks == 0) {
                    uint32_t data = measurements.back();
                    cout << sc_time_stamp() << " HalBlock -> " << (data & 0xffff) << " [#" << (readout_idx++) << "]" << endl;
                    hal_result_data.write(data);
                    hal_result_valid.write(1);
                    measurements.pop_back();
                    ticks = latency;
                } else {
                    ticks--;
                } 
            } else {
                hal_result_valid.write(0);
            }
        } else {
            hal_result_valid.write(0);
        }
    }

    void hello() {
        cout << "this is hal" << endl;
    }
 };
