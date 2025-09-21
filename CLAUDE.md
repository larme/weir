# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
WEIR is a generative art and computational geometry library written in Common Lisp. It provides a sophisticated graph-based system for creating algorithmic art with both vector (SVG) and raster (PNG) outputs.

## Development Commands

### Build and Load
```bash
# Compile the system
./compile.sh

# Load via Quicklisp (preferred)
sbcl --eval '(ql:quickload :weir)'

# Alternative loading
sbcl --eval '(load "weir.asd")' --eval '(ql:quickload :weir)'
```

### Testing
```bash
# Run full test suite
./run-tests.sh

# Run tests via ASDF
sbcl --eval '(asdf:test-system :weir)'

# Run a specific test file
sbcl --eval '(load "test/specific-test.lisp")'
```

### Docker Testing
```bash
docker build .
docker run <image-id>
```

## Architecture Overview

### The Alteration System
WEIR's most distinctive feature is its "alteration" system for graph modifications. This enables deferred, atomic operations on graph structures:

```lisp
(weir:with (wer %)
  (% (weir:add-vert? point) :res :v1)        ; Add vertex, store result as :v1
  (% (weir:add-vert? point2) :res :v2)       ; Add vertex, store result as :v2
  (% (weir:add-edge? :v1 :v2) :arg (:v1 :v2))) ; Add edge using stored results
```

Key points:
- Operations marked with `?` are alterations (deferred)
- `:res` stores results for later use
- `:arg` retrieves previously stored results
- All alterations execute atomically at end of `with` block

### Core Packages

1. **`weir`** - Main graph structure with vertices, edges, and properties
   - Spatial indexing via kdtree/zonemap
   - Group-based organization
   - Alteration system for safe modifications

2. **`vec`** - Vector mathematics (2D/3D)
   - Operations suffixed with `!` are destructive (modify in-place)
   - Broadcasting operations for lists of vectors
   - Geometric computations (intersections, angles, etc.)

3. **`rnd`** - Random number generation
   - Geometric sampling (circles, spheres, rectangles)
   - Random walks and probabilistic operations

4. **Drawing Systems**:
   - `draw-svg` - Vector output (SVG files)
   - `sandpaint` - Raster painting with random sampling
   - `bzspl` - Bezier splines

### Naming Conventions
- Functions ending with `?` are alterations (deferred operations)
- Functions ending with `!` are destructive (modify arguments)
- Functions starting with `-` are internal/private
- `$` prefix often indicates macros or special forms

### Common Patterns

When working with WEIR graphs:
```lisp
; Always use alterations within a weir:with context
(weir:with (wer %)
  ; Add vertices and edges
  (% (weir:add-vert? pos))
  ; Query operations don't need %
  (weir:get-vert wer vertex-id))
```

For vector operations:
```lisp
; Non-destructive (creates new vector)
(vec:add a b)

; Destructive (modifies first argument)
(vec:add! a b)
```

### File Organization
- `/src/packages.lisp` - All package definitions
- `/src/weir/` - Core graph system
- `/src/vec/` - Vector mathematics
- `/src/draw/` - Drawing utilities
- `/test/` - Comprehensive test suite
- `/examples/` - Usage examples

### Dependencies
Primary implementation: SBCL (Steel Bank Common Lisp)
Key libraries: alexandria, cl-svg, lparallel, zpng

### Performance Notes
- Use destructive operations (`!` suffix) in tight loops
- The zonemap spatial index is optimized for local queries
- Alteration system adds overhead but ensures consistency