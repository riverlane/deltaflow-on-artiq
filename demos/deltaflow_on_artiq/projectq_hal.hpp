#include "Python.h"

using namespace std;

class ProjectQHal {

    PyObject* module;
    PyObject* hal;

public:

    ProjectQHal() {
        module = PyImport_ImportModule("projectq_hal");
        cout << "initialised ProjectQ HAL" << endl;
        if (this->module == NULL) {
            if (PyErr_Occurred()) 
                PyErr_Print();
            std::cout << "failed to import projectq_hal python module." << std::endl;
            exit(-1);
        }
        hal = PyObject_GetAttrString(module, "hal");
        if (this->hal == NULL) {
            if (PyErr_Occurred()) 
                PyErr_Print();
            std::cout << "failed to import hal python body." << std::endl;
            exit(-1);
        }

    }

    long accept_command(long command) {
        PyObject* arg = PyLong_FromLong(command);
        PyObject* ret = PyObject_CallMethodObjArgs(
            hal,
            PyUnicode_FromString("accept_command"),
            arg,
            NULL
        );

        if(ret == Py_None) {
            return 0;
        } else {
            return PyLong_AsLong(ret);
        }
    }
};
