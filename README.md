# 3D Game Terrain Generation: Master's Capstone Project 🚀

## 📖 Overview
This repository contains the source code and project files for my **Master's Capstone Project**. The study examines and compares three distinct methods for generating 3D game terrain within the **Godot Game Engine**. 

The primary objective of this research was to perform a comparative analysis of performance metrics—specifically **RAM usage** and **Frame Rate (FPS)**—as influenced by key generation variables:
* **Load Distance:** The extent of the rendered environment.
* **Chunk Thickness:** The depth of generated voxel data.
* **Planet Radius:** The scale of spherical bodies.
* **Planet Resolution:** The level of detail in mesh and voxel distribution.

## 📁 Repository Structure
This repository is organized into four distinct Godot project folders. To run a project, open the **Godot Engine** and import the `project.godot` file located within the respective directory.

### 1. `GodotTraditionalMinecraft`
* **Method:** Traditional Voxel Generation.
* **Focus:** Examines standard cubic voxel terrain (Minecraft-style) using chunk-based loading and culling.

### 2. `GodotMeshPlanet`
* **Method:** Mesh-Only Spherical Generation.
* **Focus:** Investigates the efficiency of generating spherical planets using procedural meshes without underlying voxel data.

### 3. `GodotSphereVoxel`
* **Method:** Spherical Voxel Generation.
* **Focus:** A hybrid approach that applies voxel logic to a spherical coordinate system, testing the limits of memory consumption for complex 3D volumes.

### 4. `GodotSolarSystem`
* **Purpose:** Integration Environment.
* **Focus:** Combines generated elements into a broader "Solar System" context to evaluate performance when multiple procedural bodies are active simultaneously.



## 🛠️ Tech Stack
* **Game Engine:** Godot Engine (3.x/4.x)
* **Language:** GDScript / C# (depending on specific optimization)
* **Research Focus:** Real-time rendering optimization and memory management.

## 💻 How to Run
1. Ensure you have the **Godot Game Engine** installed.
2. Clone this repository to your local machine.
3. Open Godot and click **Import**.
4. Navigate to any of the four folders and select the `project.godot` file.
5. Press **F5** (or the Play button) to launch the simulation.

## 👤 Author
**Christopher J. Figueroa**
* **Education:** MS in Computer Science | SUNY Polytechnic Institute
* **Specialization:** Agentic AI, Machine Learning, and Multi-Agent Systems
* **Technical Profile:** Specialist in developing multi-agent systems using `PydanticAI` and `LangGraph`.
* **Contact:** [LinkedIn](https://www.linkedin.com/in/christopher-figueroa-812aa1186/) | [GitHub](https://github.com/cfig0219?tab=repositories)
