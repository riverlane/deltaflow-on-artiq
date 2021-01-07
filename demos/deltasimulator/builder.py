from os import mkdir, path
import shutil
import traceback

from examples.rabi_demo import exp_graph as rabi_demo
from deltalanguage.runtime import serialize_graph
from deltalanguage.lib import (HardwareAbstractionLayerNode,
                               ProjectqQuantumSimulator)
from deltasimulator.lib import build_graph


if __name__ == "__main__":

    build_repo = "/workdir/build"
    program_name = "rabi_demo"

    graph, store = rabi_demo.get_graph()

    q_sim = HardwareAbstractionLayerNode(
        ProjectqQuantumSimulator(1)
    )
    template_node = graph.find_node_by_name('template_QSim')
    template_node.specify_by_func(q_sim.accept_command)

    dotdf_bytes, program = serialize_graph(graph, name=program_name)

    build_graph(program,
                main_cpp="/workdir/demos/deltasimulator/main.cpp",
                build_dir='/workdir/build')

