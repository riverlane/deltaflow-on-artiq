Installation
============

Deltaflow-on-ARTIQ currently works via Docker containers `Docker <https://www.docker.com/get-started>`_ 


Supported Platforms
-------------------

Deltaflow-on-ARTIQ has been tested on Linux (Ubuntu, XUbuntu) 18.04 and 20.04 and on MacOS 10.15.15+. 
It has not been tested on Windows as well as on MacOS 11.0.x.


First steps
-----------

As a first step please clone the `deltaflow-on-artiq <https://github.com/riverlane/deltaflow-on-artiq>`_ via (for example):

.. code-block:: console
     
     git clone https://github.com/riverlane/deltaflow-on-artiq


Wait for the repository to be fully created and then initialize all the submodules via:

.. code-block:: console
     
     git submodule update --init


This will initialize and checkout the appropriate version of |Deltalanguage|_, |Deltasimulator|_, |Deltamodels|_ and all the repositories
required by the emulator.
We have currently made the decision of keeping |Deltalanguage|_, |Deltasimulator|_ as submodules for visibility but in the future they will
likely be integrated as python packages.

Creation of the docker images
-----------------------------

The easiest way to create the necessary docker images is by running the example commands explained in :doc:`examples`.

The first time the commands are executed they will look for the required docker images and if not found create them.
To summarize the commands:

.. code-block:: console
     

     make run-deltagraph
     make run-deltasimulator
     make run-kasli-emulator


The latter one will take a significant longer amount of time as it compiles and installs all the ARTIQ backend and dependecies. 
Expect an installation duration longer than 1 hr.

Following executions
--------------------

When a docker image is generated the following calls to the same command will be executed straigth away with no significant time 
overhead.

Feel free to clear your environment via:

.. code-block:: console
     
     make clean


.. note::
    
    This command would not remove the docker images previously created. It will just remove the container index files that point to them.

.. |Deltalanguage| replace:: **Deltalanguage**
.. _Deltalanguage: https://riverlane.github.io/deltalanguage

.. |Deltasimulator| replace:: **Deltasimulator**
.. _Deltasimulator: https://riverlane.github.io/deltasimulator

.. |Deltamodels| replace:: **Deltamodels**
.. _Deltamodels: https://riverlane.github.io/deltamodels