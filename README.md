# A One-Step Finite Element Method for Multiconductor Skin Effect Problems

The method solves eddy current problems in a two-conductor system using the Finite Element Method (FEM). The code is designed to handle alternating current (AC) scenarios.

The code is structured to:
1. Define the geometry and mesh of the conductors using gmsh.
2. Solve the system using octave.
3. Visualize the results, including current density and magnetic potential using octave or paraview.
4. Describe details on the numerical method and its implementation in the accompanying report.


## Repository Structure

The repository is organized as follows:
- `Code/`: Contains the implementation of the method.
    - `two_circ_cond.geo`: GMSH script for generating the mesh.
    - `mesh_two_circ_cond.m`: Mesh in matlab/octave format exported from GMSH.
    - `reaction_full.m`: Script to assemble the full mass matrix.
    - `FEM_two_conductors_AC.m`: Script containing the main function for solving the problem.
    - `FEM_eddy_currents.m`: Script to set parameters and call the main function.
    - `analytical_two_circular_conductors.m`: Script to compute the analytical solution for the impedance of two circular conductors.
    - `FEM_impedance_two_conductors.m`: Script to compute the error on the impedance of the two circular conductors.
    - `Results/`: After running the simulation contains the results of the simulations in .vtu format for visualization in paraview.

- `Report/`: Contains the report in LaTeX format
    - `main.tex`: Main report file, containing the physical model, numerical method, implementation details, and results.
    - `Images/`: Contains figures used in the report.

- `README.md`: This file, providing an overview of the project and instructions for use.


## Usage Instructions

1. Ensure you have octave installed with the `bim` package and its dependencies. To install the packages, you can use the following commands in the octave terminal:
   ```
   pkg install -forge splines msh fpl bim
   ```
2. To run the simulation and visualize the results, run the `FEM_eddy_currents.m` script in octave. The results will be saved in the `Code/Results/` folder for visualization in paraview, or the results can be directly visualized in octave changing the variable `output_type` in the `FEM_eddy_currents.m` script to `octave`.
3. To compute the error in impedance, run the `FEM_impedance_two_conductors.m` script. 
4. To change the parameters of the simulation, modify the `FEM_eddy_currents.m` script. You can adjust the frequency, current values, material properties, and mesh file name as needed.
5. The mesh can be modified by editing the `two_circ_cond.geo` file and regenerating the mesh using gmsh. After modifying the geometry, the mesh need to be exported again to the `.m` format using gmsh's export functionality. If the mesh is modified, ensure to update the mesh parameters in the `FEM_impedance_two_conductors.m` accordingly.