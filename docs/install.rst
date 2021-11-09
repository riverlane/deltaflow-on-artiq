Installation
============

Deltaflow-on-ARTIQ currently works via Docker containers
`Docker <https://www.docker.com/get-started>`_ 

Supported Platforms
-------------------

Deltaflow-on-ARTIQ has been tested on Ubuntu 18.04 and 20.04 and on
MacOS 10.15.15+. 

For Mac users we recommend to configure your Docker Desktop
to use at least 4 **CPUs**, 4GB of **Memory** and allow more than 30GB for your 
**Disk Image size**. 
Deltaflow-on-ARTIQ has not been tested yet on Windows.

Workflow
========

Obtain the code
---------------

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

Container images
-----------------------------

We provide pre-generated Docker images to minimise the installation time. 
We discourage you from modifying the tag version of the docker image (defined in the 
base Makefile) to keep your environment in line with the release tag of the repository.

To obtain a local version of the image run:

.. code-block:: console
     
    make image

Following executions
--------------------

After an initial fetch of the docker image you can run our demos in any order.
Please refer to the next section in the manual.

Feel free to clear your environment via:

.. code-block:: console
     
    make clean


.. note::
    
    This command would not remove the Docker images previously downloaded.
    It will just remove the container index files that point to them.


.. |Deltalanguage| replace:: **Deltalanguage**
.. _Deltalanguage: https://riverlane.github.io/deltalanguage

.. |Deltasimulator| replace:: **Deltasimulator**
.. _Deltasimulator: https://riverlane.github.io/deltasimulator

.. |Deltamodels| replace:: **Deltamodels**
.. _Deltamodels: https://riverlane.github.io/deltamodels
