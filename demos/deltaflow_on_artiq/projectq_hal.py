
from deltalanguage.lib.hal import HardwareAbstractionLayerNode
from deltalanguage.lib.quantum_simulators import ProjectqQuantumSimulator

hal = HardwareAbstractionLayerNode(ProjectqQuantumSimulator(1))
