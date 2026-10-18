# CryptoQUIP Solver (Julia)

A command-line tool written in Julia to interactively solve daily letter-substitution CryptoQUIP puzzles (as seen in newspapers like the *Star of Mysore*).

## Features
- **Interactive Substitutions:** Map cipher letters to plain text (e.g., `U=W` or batch input `U=W, K=E`).
- **Frequency Analysis:** Toggle 2-digit letter frequency counts under the cipher key using `F`.
- **Undo & Clear:** Step back through edits using `Z` or reset the board using `C`.
- **Colored Output:** Highlights solved letters in bright cyan terminal output.
- **Save Solutions:** Export completed solutions to timestamped text files (`cqSolution-YYMMDD.txt`).

## Acknowledgements
- CryptoQUIP is a feature that appears in the Star of Mysore. The present tool is a cool alternative to solving it with pen and paper.
- The present script was developed using Gemini PRO as an aid to learning julia scripting.

## Requirements
- [Julia](https://julialang.org/downloads/) (v1.6 or higher recommended)

## Usage
Run the script directly from your terminal:

```bash
julia cryptoquip.jl
