FAQ
===

* **How can I collaborate with Riverlane on Deltaflow or use Deltaflow as
  a commercial product?**

  We’re happy to speak about that, send an email to deltaflow@riverlane.com

* **Where can I find more information about Riverlane's activities?**

  You can follow us on Twitter and Linkedin. You can also signup via our 
  website to receive our newsletter and watch our videos on YouTube.

* **How can I contribute to Deltaflow?** 

  * If you have a few minutes: It would be incredibly helpful to us if you
    complete our `survey <https://amyflower.typeform.com/to/LnovZGSj>`_.

  * If you found a bug: We would be ever so grateful if it create a
    `GitHub Issue <https://github.com/riverlane/deltaflow-on-artiq/issues>`_.

  * If you want to contribute to Deltaflow: Please follow this simple 
    `tutorial <https://github.com/firstcontributions/first-contributions>`_.
    This is an early release of the project and we’re still figuring things
    out so please bear with us.

* **I need help, who can help me?**

  Send an email to deltaflow@riverlane.com and we’ll get back to you asap. 

* **Have you installed Deltaflow on a real quantum computer yet?**

  Yes, we have, in collaboration with Oxford Ionics and the University of
  Oxford.
  You can read more about this
  `here <https://www.riverlane.com/news/2020/09/commercial-breakthrough-following-success-of-deltaflow-os-trials/>`_.

* **Who is using Deltaflow?**

  In a project founded by Innovate UK, we are working together with Arm,
  Duality Quantum Photonics, Hitachi Europe Ltd, Oxford Ionics,
  Oxford Quantum Circuits, Seeqc, and Universal Quantum.
  Read more about this
  `here <https://www.riverlane.com/news/2020/05/uk-companies-to-build-radically-new-operating-system-for-quantum-computers/>`_.
  If you are interested in using Deltaflow in your lab, contact us at
  deltaflow@riverlane.com.

* **How fast can my code go?**

  It depends!
  Your CPU nodes will run on server-grade hardware, and we add no overhead
  to fast feedback loops on the FPGA, so as fast as you can make it go!

* **Can I use Python libraries?**

  In simulation, you can use anything you have installed!
  When the first commercial devices are available, we will make a process
  for adding a library available but basics such as numpy will be there.

* **What versions of Python do I need to run?**

  3.8 or later.
  We are working on supporting more versions.

* **Which operating system do I need to run Deltaflow?**

  Deltaflow-on-ARTIQ has been tested on Ubuntu 20.04 and on MacOS 10.15.15+.
  It has not been tested on Windows as well as on MacOS 11.0.x. 
  We are working on supporting more versions.

* **I want to run Deltaflow in my lab, what do I have to do?**

  **If you run ARTIQ:**
  It can be done but there is still some manual work that you need to do
  to connect a Deltaflow graph with hardware in the lab.
  If you are interested and need help, contact us.
  We are working on a runtime that will automate that process.

  **If you don’t run ARTIQ:**
  We are building a runtime to make it easy to use Deltaflow even if you
  don’t run ARTIQ.
  This will be released soon.
  Email us if you’re interested and want to know more.

* **Can I use Deltaflow for free?**

  Yes, you can.
  The following licenses are used for the various components of Deltaflow.

  * Deltalanguage: MIT license + Commons Clause

  * Deltasimulator: MIT license + Commons Clause

  * Deltamodels: MIT license + Commons Clause

  * ARTIQ emulator: LGPL 3
 
  MIT license + Commons Clause means you can build libraries in it and sell
  on those libraries or use it for any other purposes for free - the only
  thing you can’t do is re-sell what we have released.

* **How can I modify the ARTIQ emulator to test new ideas?**

  **To understand how an ARTIQ kernel works in the bigger system:**
  Have a look at our ARTIQ kernel
  (:code:`emulator/SoCBuilder/startup_kernel.py`) for an example of how we
  read data from the Artiq-HAL-Interface interface. 

  **To play with the ARTIQ firmware without affecting your lab:**
  Have a look at emulator/artiq/artiq/firmware.
  You can force a recompilation of the firmware by calling a make clean

  **To develop hardware models to connect to your RTIO outputs:**
  Look into :code:`emulator/SoCBuilder/virtual_kasli.py` to see how we are
  adding a simple TTL output block.
  You can add more complex drivers to the RTIO.
  Also, look into :code:`emulator/quantum_interface.hpp` to understand how
  we implemented a simple way to deserialise I/O signals.

* **Can I use the ARTIQ emulator independent of Deltaflow?**

  We haven’t released it but we do have a standalone version of the emulator
  (currently in beta testing).
  Please contact us (deltaflow@riverlane.com) if you want to use it.

* **Do I have to use this HAL? I want to use a different HAL!**

  We can help you implement other types of HALs - or you can do it yourself.
  We can work with pretty much any HAL that you like.
  In the Innovate UK project that we are currently running, we are
  discussing how to standardise this HAL with our partners. 

* **Can I use Deltaflow below the HAL?**

  With the
  `Micromotion example <https://riverlane.github.io/deltalanguage_internal/dev/examples/examples.html>`_
  we are showing you how Deltaflow can be used to control low-level
  hardware and implement basic experiments.
  This is still in the works.

* **How does a node map to a computational unit?**

  Each node in your graph represents a portion of computation that you are 
  executing as either Python (implicitily targetting a CPU) or Migen (targetting
  an FPGA). In both the scenarios with the current implementation of Deltalanguage 
  you are not specifing where they run. We are still tuning this part of the 
  process and it will be part of the Deltaruntime. In future you will be able to 
  specify which computational units takes care of which node execution with the
  communication between nodes handled by the Deltaruntime. 

* **How is Deltaflow different from Qiskit, Q# etc.?**

  Deltaflow is a dataflow language (a bit akin to Tensorflow) so Qiskit and
  Deltaflow are very much compatible.
  "Translating" Qiskit to Deltaflow involves writing a dataflow programme and
  filling the nodes of the dataflow programme with Qiskit.
  Deltaflow allows you to define CPU nodes and FPGA nodes which are based
  on Python and Migen, respectively.
  Any Python based language can, in principle, be used in the CPU nodes.

  The point of Deltaflow is that it allows you to programme the FPGA layer
  (i.e. the local control) in the quantum computer, contributing to better
  hardware-software co-development at that level of the stack.
  Have a look at `our white paper <https://arxiv.org/abs/2009.08513>`_
  which describes the importance of local control. 

  Deltaflow can also be used as a way of making low-level control stack
  development easier.
  Have a look at our
  `Micromotion example <https://riverlane.github.io/deltalanguage_internal/dev/examples/examples.html>`_
  to get a flavour.
