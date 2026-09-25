# GD-ASM: A custom Assembly IDE and compiler for homemade CPUs

A lightweight assembly editor and compiler designed for custom and homebrew CPU architectures.

> **Status: Preliminary Release**
>
> This project is currently in early development. The core editor and compiler are functional, but support for customizable CPU architectures and advanced assembly features is still being developed.

## Features

* **Tabbed code editor**

  * Edit multiple assembly files at once
  * Syntax highlighting for opcodes, values, and labels
  * Automatic parsing while editing
  * Error highlighting and hover tooltips
  * supports decimal, binary, and hex numbers (example: 13, 0b1101, 0xd)
  * Adjustable editor zoom

* **Integrated compiler**

  * Build directly from the editor
  * Generates EEPROM HEX output
  * Detailed compiler output

* **Live diagnostics**

  * Errors are detected while editing
  * Dedicated Errors panel
  * Click errors to jump directly to the source line

* **Symbol navigation**

  * Dedicated Symbols panel
  * Lists all labels
  * Click a label to jump to its definition

* **Compiler output**

  * Color-coded errors, warnings, information, and success messages
  * Clickable source locations

* **Customizable layout**

  * Resizable editor and docks
  * Errors, Symbols, and Compiler Output docks
  * Docks can be shown or hidden

* **Keyboard shortcuts**

  * Shortcuts are available for common file, editing, viewing, and build operations

## Getting Started

1. Create a new assembly file or open an existing one
2. Write your assembly code in the editor
3. The compiler will automatically parse the file
4. Fix any errors shown in the Errors panel
5. Select **Run -> Build** or use the build keyboard shortcut
6. The compiled .HEX file will be generated alongside the source file

### Example

```asm
.main
    ldi 5
    sto 0x4c
    jmp .main
```

The syntax and available instructions depend on the currently configured assembly language and CPU.

## Output

The current compiler produces a .hex file for a testing CPU design similar to the [BMOW Nibbler](https://www.bigmessowires.com/nibbler/).

Additional output formats are planned.

## Roadmap

The long-term goal is to make the compiler capable of targeting a wide variety of custom and homebrew CPU architectures.

Planned features include:

* [ ] Variables and constants
* [ ] `include` support
* [ ] Pseudoinstructions
* [ ] Custom assembly language definitions
* [ ] Visual CPU/instruction definition editor
* [ ] Custom instruction and operand bit layouts
* [ ] Configurable instruction sizes
* [ ] Microcode generation
* [ ] Multiple ROM/output targets
* [ ] Binary output
* [ ] Configurable output formats
* [ ] Preset and user-defined output formats
* [ ] Project/file-tree support
* [ ] Preferences and editor settings

## Current Limitations

This is an early release, so several parts of the system are intentionally limited:

* Only the currently selected source file is built
* Labels are currently the only supported symbols
* The output format is currently fixed
* CPU architecture configuration is not yet exposed through the editor
* There is no project manager or file tree
* Advanced assembly features such as includes, constants, and pseudoinstructions are not yet available

## Contributing

The project is still in an early stage, so the architecture may change significantly between releases.

Suggestions, bug reports, PRs, and ideas for supporting additional CPU architectures are welcome.
