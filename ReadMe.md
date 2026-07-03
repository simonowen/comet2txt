# comet2txt

A Python program to convert SAM Coupé Comet assembler code to ASCII text.

The output text can be assembled using pyz80 for easier SAM development on
modern operating systems.

## Installation

Installing the tool doesn't require the source code or even Python, just uv.

Install [uv](https://docs.astral.sh/uv/#installation) if not already installed.
Windows users can do that using:

```shell
winget install --id=astral-sh.uv -e
```

Then install the `comet2txt` command using:

```shell
uv tool install comet2txt
```

## Usage

```sh
usage: comet2txt [-h] [-q] [-V] input_file [output_file]

Convert Comet assembler source to text

positional arguments:
  input_file            input .S file to convert
  output_file           output .asm file to write

options:
  -h, --help            show this help message and exit
  -q, --quiet           suppress conversion warnings
  -V, --version         show program's version number and exit
```

The input file is a .S file containing your Comet source code. Use `SCADM` or
`SamDsk` (not to be confused with SAMdisk!) to extract this from a disk image.

If no output file is supplied the converted output is written to the console.

## Alternatives

Here are some existing solutions to perform the conversion, each with drawbacks:

### COMET2A

Simon Cooke's Comet source convertor was released in 1995 and can convert in
both directions. It's a SAM program but can be run on real hardware or under
emulation to write the text output to a disk. The text can be extracted from a
disk image using tools such as `SCADM`.

There's an issue with nested comments that occur when commenting out code that
already has an end of line comment. The nested comment is offset in the output
and may be truncated or clipped entirely.

### COM2TXT

Edwin Blink released a DOS utility in 2000, which was the official method to
convert files on the PC for many years.

Modern 64-bit versions of Windows can no longer run DOS 16-bit binaries so it
can no longer be executed directly. It's still possible to use under an emulated
environment such as DOSbox or VirtualBox, or even FreeDOS booted natively, but
it's less convenient.

### Comet Print

Comet has a print function accessed via the Sym-C command menu, then entering
`P` to send the source listing to a connected printer. This uses the same
formatting code as the editor so compatibility is guaranteed. Running Comet
under SimCoupe you can configure a virtual printer to capture the print output
to a text file.

There's an issue with long source code lines that are clipped at 64 characters.
The editor only shows 64 characters but some source files contain 66, so the
final 2 characters of long comments may be lost during printing.

## ChangeLog

### 2026-07-03

- Released as PyPi package v1.0.0, with API and CLI interfaces.
- Upgraded project development and build environment.

### 2025-05-05

- Initial commit.

## Links

comet2txt - <https://github.com/simonowen/comet2txt/>  
pyz80 - <https://github.com/simonowen/pyz80/> (best used via VSCode extension)  
SCADM - <https://www.worldofsam.org/products/scadm>  
SimCoupe - <https://simonowen.com/simcoupe/>
