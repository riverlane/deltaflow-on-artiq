Installation
============

Deltaflow-on-ARTIQ currently works via Docker containers
`Docker <https://www.docker.com/get-started>`_ 

Supported Platforms
-------------------

Deltaflow-on-ARTIQ has been tested on Ubuntu 18.04 and 20.04 and on
MacOS 10.15.15+. For Mac users we recommend to configure your Docker Desktop
to use at least 4 **CPUs**, 4GB of **Memory** and allow more than 30GB for your 
**Disk Image size**. 
Deltaflow-on-ARTIQ has currently not been tested on Windows.

First steps
-----------

At first clone the repo:

.. code-block:: console
     
    git clone https://github.com/riverlane/deltaflow-on-artiq


Then initialize all the submodules via:

.. code-block:: console
     
    git submodule update --init

This will initialize and checkout the appropriate version of
|Deltalanguage|_, |Deltasimulator|_, |Deltamodels|_ and all the repositories
required by the emulator.
We have currently made the decision of keeping |Deltalanguage|_,
|Deltasimulator|_ as submodules for visibility but in the future they will
likely be integrated as python packages.

Creation of the Docker images
-----------------------------

The easiest way to create the necessary Docker images is by running
the example commands explained in :doc:`examples`.

The first time the commands are executed they will look for the required Docker
images and if not found create them.
To summarize the commands:

.. code-block:: console     

    make run-deltagraph
    make run-deltasimulator
    make run-kasli-emulator

The latter one will take a significant longer amount of time as it compiles
and installs all the ARTIQ backend and dependecies. 
Expect an installation duration longer than 1 hr.
Each next iteration will be significantly faster as all binaries are
precompiled.

Following executions
--------------------

When a Docker image is generated the following calls to the same command will
be executed straigth away with no significant time overhead.

Feel free to clear your environment via:

.. code-block:: console
     
    make clean


.. note::
    
    This command would not remove the Docker images previously created.
    It will just remove the container index files that point to them.

.. |Deltalanguage| replace:: **Deltalanguage**
.. _Deltalanguage: https://riverlane.github.io/deltalanguage

.. |Deltasimulator| replace:: **Deltasimulator**
.. _Deltasimulator: https://riverlane.github.io/deltasimulator

.. |Deltamodels| replace:: **Deltamodels**
.. _Deltamodels: https://riverlane.github.io/deltamodels
