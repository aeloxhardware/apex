# apex
If the UI is the control panel and the algorithm is the reactor, this is the rocket meant to lead to the *Apex* of the sky.

## What is in this repository

Apex is assembled here from two repositories, copied at pinned commits (see
[`integration/sources.json`](integration/sources.json)):

| Folder | Source | Content |
|---|---|---|
| [`slicer-engine/`](slicer-engine/) | [apex-engine](https://github.com/aeloxhardware/apex-engine) | slicing engine (Python and C++) |
| [`slicer-ux/`](slicer-ux/) | [apex-ui](https://github.com/aeloxhardware/apex-ui) | user interface (React, Babylon.js, Electron, native editing kernel) |

Do not edit these folders here: develop in the source repositories, then run
`integration/sync.sh`. The current version is in [`VERSION`](VERSION). The rules shared by
the engine and the interface are in [`integration/RULES.md`](integration/RULES.md).

## Credits & Citations

Apex builds on the work below. Licences are those published by each author.

**Algorithm and research**

- **Thank you to [Joshua Bird](https://github.com/jyjblrd) and his [S4 Slicer](https://github.com/jyjblrd/S4_Slicer)** (GPL-3.0), whose work inspired this project. The Bird path has been removed from the engine's main branch and is kept in its `bird_old` branch, with its notices. Please cite it (see `slicer-engine/CITATION.cff`).
- Heat method for geodesic distance: Crane, Weischedel and Wardetzky, *Geodesics in Heat* (the field of step 4).
- Minimum-weight polygon triangulation (Klincsek), triangle-triangle intersection (Möller), Dijkstra shortest paths, marching tetrahedra, the Viterbi algorithm, the Householder QR and the Hann window.
- Inspirations: [Orca Slicer](https://github.com/OrcaSlicer/OrcaSlicer), [Bambu Studio](https://github.com/bambulab/BambuStudio), [Ultimaker Cura](https://github.com/Ultimaker/CuraEngine).

**Engine: meshing, geometry and numerics**

| Project | Author | Licence | Use |
|---|---|---|---|
| [TetGen](https://wias-berlin.de/software/tetgen/) | Hang Si, WIAS Berlin | AGPL-3.0 | tetrahedral meshing, run in a separate process |
| [tetgen](https://github.com/pyvista/tetgen) (Python module) | PyVista developers | MIT | calls TetGen from Python |
| [PyMeshFix](https://github.com/pyvista/pymeshfix) | PyVista developers, after MeshFix by Marco Attene | AGPL-3.0 | optional repair of self-intersecting meshes |
| [trimesh](https://github.com/mikedh/trimesh) | Michael Dawson-Haggerty and contributors | MIT | mesh loading, repair, sections, distances |
| [Manifold](https://github.com/elalish/manifold) (manifold3d) | Emmett Lalish and contributors | Apache-2.0 | boolean operations |
| [Rtree](https://github.com/Toblerity/rtree) | Sean Gillies and contributors (on libspatialindex) | MIT | spatial index |
| [NumPy](https://numpy.org) | NumPy developers | BSD-3-Clause | array computing |
| [SciPy](https://scipy.org) | SciPy developers | BSD-3-Clause | sparse solvers, k-d trees |
| [NetworkX](https://networkx.org) | NetworkX developers | BSD-3-Clause | graphs |
| [Shapely](https://github.com/shapely/shapely) | Sean Gillies and contributors (on GEOS, LGPL-2.1) | BSD-3-Clause | 2D offsets and clipping |

**Engine: native core** (vendored in `slicer-engine/cpp/third_party/`)

| Library | Version | Licence | Use |
|---|---|---|---|
| [Eigen](https://eigen.tuxfamily.org) | 3.4.0 | MPL-2.0 | linear algebra |
| [Clipper2](https://github.com/AngusJohnson/Clipper2) | 2.0.1 | BSL-1.0 | polygon offsets for walls and infill |
| [volk](https://github.com/zeux/volk) | vulkan-sdk-1.4.363.0 | MIT | Vulkan loader |
| [VulkanMemoryAllocator](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator) | 3.3.0 | MIT | GPU memory |
| [pybind11](https://github.com/pybind/pybind11) | build dependency | BSD-3-Clause | Python bindings |

**Interface**

| Project | Author | Licence | Use |
|---|---|---|---|
| [Babylon.js](https://www.babylonjs.com) | Microsoft and the Babylon.js community | Apache-2.0 | 3D view, model loading, toolpath rendering |
| [Electron](https://www.electronjs.org) | OpenJS Foundation | MIT | desktop application, editing-kernel process |
| [React](https://react.dev) | Meta | MIT | interface |
| [Vite](https://vite.dev) | Evan You and contributors | MIT | build and dev server |
| [Framer Motion](https://motion.dev) | Framer | MIT | panel animations |
| [shadcn/ui](https://ui.shadcn.com) | shadcn | MIT | component base |
| [Radix UI](https://www.radix-ui.com) | WorkOS | MIT | accessible primitives |
| [Tailwind CSS](https://tailwindcss.com) | Tailwind Labs | MIT | layout |
| [Lucide](https://lucide.dev) | Lucide contributors | ISC | icons |
| [Tabler Icons](https://tabler.io/icons) | Paweł Kuna | MIT | icons |
| [Recharts](https://recharts.org) | Recharts contributors | MIT | charts |
| [Sonner](https://sonner.emilkowal.ski) | Emil Kowalski | MIT | notifications |
| [Liquid Glass Studio](https://github.com/iyinchao/liquid-glass-studio) | Charles Yin (iyinchao) | MIT | refraction, dispersion and reflection shaders of the glass panels and the edit node; licence notice kept in `slicer-ux/src/components/edit-node/liquidGlass.ts` |
| [GLSL-Color-Functions](https://github.com/Rachmanin0xFF/GLSL-Color-Functions) | Rachmanin0xFF | MIT | colour conversions in the glass shaders |
| [Thinking Orbs](https://github.com/yogesharc/thinking-orbs) (`@yogesharc/thinking-orbs`) | yogesharc | MIT | "reasoning" orb of the Assistant (lab page for now); the MIT notice must be kept in distributions |
| [Pixabay](https://pixabay.com) | Pixabay artists | Pixabay Content License | application sounds |

**Fonts**

| Font | Author | Licence |
|---|---|---|
| Orbitron | Matt McInerney | SIL Open Font License 1.1 |
| Oxanium | Severin Meyer | SIL Open Font License 1.1 |
| Russo One | Jovanny Lemonad | SIL Open Font License 1.1 |
| Ethnocentric | Typodermic Fonts | Typodermic licence |

**Development only** (not shipped): pytest (MIT), CMake (BSD-3-Clause) and Ninja (Apache-2.0); in the engine's research branch, libigl (MPL-2.0), potpourri3d (MIT), Matplotlib (Matplotlib licence) and Pillow (MIT-CMU).

**Assets**

- Toolhead model `aetheris-4`: based on the BIQU H2 V2S Lite hot end.
- Test models in `slicer-engine/res/test_models/`: the Benchy-derived and other community models still need their authors and licences listed.

**Licence note.** TetGen and PyMeshFix are AGPL-3.0, S4 Slicer is GPL-3.0. This fits the project's decision: free and open-source software, only the printer is sold. The network clause of the AGPL has no effect for a desktop application.

## License

[GNU GPL 3.0](LICENSE)
