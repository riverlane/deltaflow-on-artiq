import asyncio
from os import mkdir, path, system
import subprocess
import shutil
import traceback

from examples.rabi_demo import exp_graph as rabi_demo
from deltalanguage.runtime import serialize_graph

from deltasimulator.build_tools import BuildArtifact, write
from deltasimulator.build_tools.environments import (CPPEnv,
                                                   HostEnv,
                                                   PythonatorEnv,
                                                   VerilatorEnv,
                                                   WiringEnv)
from deltasimulator.lib import generate_wiring
import time

def finalize_build():
    with open('/workdir/demos/deltaflow_on_artiq/builder.flags') as f:
        cmd = f.read().splitlines()
    system(" ".join(cmd))

if __name__ == "__main__":

    build_repo = "/workdir/build"
    program_name = "rabi_demo"
    sc_hal_hpp_file = "sc_hal_block.hpp"
    projectq_hal_hpp_file = "projectq_hal.hpp"
    main_cpp_file = "deltaflow_emulator.cpp"
    hal_py_file = "projectq_hal.py"

    try:
        shutil.copy(
             "/workdir/demos/deltaflow_on_artiq/" + main_cpp_file,
            build_repo + "/" + main_cpp_file
        )

        shutil.copy(
             "/workdir/demos/deltaflow_on_artiq/" + sc_hal_hpp_file,
            build_repo + "/" + sc_hal_hpp_file
        )

        shutil.copy(
             "/workdir/demos/deltaflow_on_artiq/" + projectq_hal_hpp_file,
            build_repo + "/" + projectq_hal_hpp_file
        )

        shutil.copy(
             "/workdir/demos/deltaflow_on_artiq/" + hal_py_file,
            build_repo + "/" + hal_py_file
        )
    except FileExistsError:
        pass

    graph, _ = rabi_demo.get_graph()
    dotdf_bytes, program = serialize_graph(graph, name=program_name)

    node_bodies, node_inits, wiring = generate_wiring(program)

    # write artifacts to build repository
    for build_artifact_name, build_artifact_data in wiring.items():
        print (f"writing: {build_artifact_name} into {build_repo}")
        with open(build_repo + f"/{build_artifact_name}", "wb") as f:
            write(build_artifact_data, f)

    # write python bodies to build repository
    for py_build_artifact in node_bodies:
        print(f"py_build_artifact: {py_build_artifact}")
        print(f"py_build_artifact: {type(py_build_artifact)}")
        with open(build_repo + f"/{py_build_artifact.name}", "wb") as f:
            write(py_build_artifact, f)

    # write init roms to build repository
    for init_rom_artifact in node_inits:
        with open(build_repo + f"/{init_rom_artifact.name}", "wb") as f:
            write(init_rom_artifact, f)

    # start compilation step
    with HostEnv(dir=build_repo) as env:
        main_cpp = BuildArtifact(name=main_cpp_file, env=env)
        main_h = BuildArtifact(name=program_name + ".h", env=env)
        main_a = BuildArtifact(name=program_name + ".a", env=env)
        #verilated_o =  BuildArtifact(name="verilated.o", env=env)

    with CPPEnv() as cpp:
        main = cpp.compile_and_link(
            [main_h],
            [main_a],
            main_cpp
        )

    # Compilation workaround - the ar becomes meaningless for another build in a different container.
    finalize_build()
